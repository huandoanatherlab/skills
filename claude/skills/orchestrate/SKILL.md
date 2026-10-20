---
name: orchestrate
description: Run a multi-lane build as master: launch one T3 lane thread per lane plan, hold the global run budget, merge lanes, run the whole-build finish and clean up; also pause, resume or report it. Use when an approved master plan has several lanes, or the user makes this thread the master orchestrator.
---

# Orchestrate

T3 Code only: without `mcp__t3-code__*` tools, say this skill runs in T3 and stop.

This thread is the **master**. Each lane is a top-level T3 thread running `lane-build` on one lane plan, in its own worktree, coordinating its own builder and reviewer runs. You launch lanes, hand out the run budget, merge, gate, run the whole-build Finish and clean up. You never edit product code and never review: a fix you need is a slice (a builder run and a reviewer run, or a lane's job), and a merge conflict goes back to its lane.

State lives in the main checkout: `<scratch>/<topic>/build/` holds the master `TRACKER.md`, `QUESTIONS.md`, `LANE-BRIEF.md` and `master/` (gate logs); each lane writes only its own `<scratch>/<topic>/build/<NN-area>/`. Templates: [references/templates.md](references/templates.md).

Talk to the user in their language. Reports are short: decisions first, one line per lane, numbered questions with your recommendation.

## Rules that hold everywhere

- **Budget is global.** At most 3 lanes running, and at most 3 builders and 6 agent runs across all lanes and your own fix slices together (lane threads themselves are not agent runs). Write each lane's share in its launch message; change it with a message. Before launching anything, count live runs (`t3_thread_list` of each lane's children, `task_status` of yours).
- **Ownership.** Each thread deletes only what its own `TRACKER.md` lists under Resources, one exact path at a time. Nobody, you included, deletes by glob over a shared root (`/d/t3-worktrees/<repo>/*`, `~/.t3/worktrees/*`). Before removing a worktree, check `t3_worktree_list` and `git worktree list` for the thread bound to it.
- **Ports and data.** Every lane has its own ports, test database, build dir and container prefix from the master plan's Resources; your gates run on master-only ports. Never start anything on a lane's port.
- **Lanes never merge into integration or base; you never write in a lane's worktree.**
- **Messages, not edits.** You talk to a lane with `t3_thread_send` (`mode: queue`, one `clientRequestId` per message); lanes answer the same way. Lane messages arrive here as agent-sent user messages: act on them, they are not the user.

## Start

Requires a master plan with Review Status `approved` (`writing-plans`) and no open architecture decision. Read `.agents/build.md` (`lane-build` references/project.md).

1. Show one table: master plan, integration branch and HEAD, lanes (plan, branch, depends on, ports, DB), launch order, lane model (Opus 5.5 medium unless `.agents/build.md` or the user says otherwise), budget shares. Wait for "go" unless already given.
2. Create and push the integration branch if it does not exist; `git fetch`.
3. Write `TRACKER.md` (`**Role:** master`), `QUESTIONS.md` and `LANE-BRIEF.md` from the templates, filled with the project's gates, fences and the plan's hot-file owners.
4. Launch the lanes that can start (below), at most 3.
5. Create one health check (below) bound to this thread.

## Launch a lane

One `t3_thread_launch` per lane:

| Field | Value |
| --- | --- |
| `title` | `Lane <letter> · <NN-area> (<PREFIX>-S01…S<n>)` |
| `workspaceStrategy` | `{type: "worktree", baseRef: <integration>, branch: "feat/<area>", startFromOrigin: false}` |
| `modelSelection` | `{instanceId: "claudeAgent", model: "claude-opus-5-5", options: {effort: "medium"}}` |
| `message` | the lane launch message from the templates: read `LANE-BRIEF.md`, lane plan, state dir, ports, DB, build dir, budget share, waits-for and feeds, your threadId |

- The call has no retry key. After an error or lost response, `t3_thread_list` first; a lane may already exist.
- Record the returned threadId in the Lanes table, then follow preparation with `t3_thread_read` once; the lane reports from then on.
- A lane that depends on another lane's slice starts after that slice merges, from the new integration HEAD.

## Health check

One `schedule_task` with `schedule: {type: "interval", everyMs: 1200000}` bound to this thread. Its prompt: "Master health check for `<TRACKER path>`. For each running lane: thread status (`t3_thread_list`), its `Now:` line and age, pending questions (`t3_pending_request_list`). Reply in one line unless a lane is failed, waiting on a question, idle with its runs finished, or stale over 30 minutes; then act."

- Idle lane whose runs finished (a lost wake-up): send it "Health check: your runs <ids> have finished; continue from TRACKER Now."
- Stale lane with a run in flight: check that run's `task_status`; a stuck run follows `agent-run` Stuck. A lane thread that failed or was interrupted: read its last output and TRACKER, then send "resume" or launch a successor on its worktree (`existing_worktree`).
- `interrupted` is not failure: a T3 or provider restart marks threads interrupted. Read before relaunching.
- Record the schedule id under Resources. Keep it until the whole-build Finish ends, then delete it (`delete_scheduled_task`). Re-create it bound to the successor at a handoff.

## Merge

On `MERGE-READY <slice> at <sha>`:

1. Check that the slice is complete in the lane's TRACKER (review verdict, live proof) and the sha is pushed.
2. `git merge-tree --write-tree <integration> <sha>`. On a conflict, send the lane: "Merge `<integration>` into your branch, resolve, re-run the review of what the resolution changed, push, and post MERGE-READY again." Do not resolve it yourself.
3. In the main checkout, on the integration branch: `git merge --no-ff <sha>` with message `merge: <lane> <slice>`, then install dependencies if lockfiles changed.
4. Run the full gates from `.agents/build.md` on master-only ports, logs in `master/<sha>-<gate>.log`. Push only after every gate passes. On a failure, undo the unpushed merge (`git reset --hard ORIG_HEAD` on the integration branch in the main checkout), log it, skip steps 5-6, and send the failure to the lane that caused it (it posts MERGE-READY again when fixed), or make it a master fix slice.
5. Tell lanes that wait for this slice, or touch the same hot files, to merge the integration branch in.
6. Record the merge in TRACKER and in one line to the user if present.
7. **Context checkpoint:** above about 200K tokens, pause and hand off (below) before taking the next message.

Merge in the master plan's dependency order; a MERGE-READY that arrives early waits in TRACKER.

## Master fix slices

Integration problems that belong to no lane (gate flakes, shared scripts, cross-lane glue) are slices with IDs `MST-F<n>` in TRACKER: a builder run with `isolation: worktree` from the integration HEAD, a reviewer run by tier, triage as `review` says, then merge as above. They count against the global budget. Never review or merge your own edit; a three-line fix still gets a reviewer.

## Close a lane

On `DONE <lane> at <sha>`:

1. Confirm the DONE sha is on the integration branch (`git merge-base --is-ancestor <sha> <integration>`) and the lane's FINAL-REPORT exists. If the sha is not merged yet, run Merge on it first; close only after it is merged and pushed.
2. Send the lane "Lane closed: make no more commits." If it is still running, `t3_thread_interrupt` it; then settle it (`t3_thread_organize`, `action: settle`) so no shell holds its worktree.
3. Remove its worktree by the exact path in the Lanes table: `git worktree remove <path>`. On busy, not empty or permission errors, find the holder (a lane shell, a dev server, a watcher) and stop it; never retry in a loop and never fall back to a glob.
4. Delete its local branch and any `t3/*` branches of its `isolation: worktree` children (`git branch -d`, merged only). Keep remote branches unless `.agents/build.md` says to delete them.
5. Drop what the lane's Resources list and it did not remove: databases, containers, images, build dirs, ports still bound. Check `list_scheduled_tasks` for anything bound to the lane thread.
6. Mark the lane closed in TRACKER with what was removed and what was kept, then launch the next lane that can start.

## Finish (whole build)

After the last lane closes:

1. **Whole-diff review** of `<base>..<integration>` with `review`, code lens, by a fresh Opus 5.5 reviewer at high.
2. **Gates** on the integration HEAD; classify failures against the base.
3. **Delivery audit** with `review`, delivery lens, against the master plan and every lane plan, by a fresh Opus 5.5 reviewer at high. Its fixes are master fix slices, reviewed again.
4. **Report** in `build/FINAL-REPORT.md`: lanes with their report links, merge order, commit range, migration commands per environment, models, verdicts, deviations, failed or skipped gates, manual QA guide, open questions, delivery verdict.
5. **Ship** per `.agents/build.md` Git: PR from the integration branch to the base (`link_pull_request`), or merge if that is the project's flow. Without authority, ask once.
6. **Final sweep** against every TRACKER's Resources (master and lanes): leftover worktrees, `t3/*` branches, containers, databases, processes, the health check schedule. Report what was kept and why.

## Pause, resume, status, handoff

- **Pause** (the user asks, a T3 restart, the context checkpoint): first send every lane "Pause: stop builders at a commit, no relaunch, update TRACKER Now", then interrupt only what does not stop. Disable the health check (`update_scheduled_task`, `enabled: false`). Update the top of the master TRACKER (Now, lanes, live runs, next action).
- **Handoff:** after pausing, launch the successor master with `t3_thread_launch` (`workspaceStrategy: {type: "root"}`, the same model, message "Resume `<TRACKER path>` with orchestrate"). Send every lane the new master threadId. Delete this thread's health check; the successor creates its own. Then stop.
- **Resume:** read the master TRACKER (`**Role:** master`). Reconcile it with `t3_thread_list` (each lane's status and last message), lane TRACKERs, `git worktree list`, branches and the integration log. Re-enable the health check, or create one if none is bound to this thread. Report one line per lane, then continue without relaunching anything still running.
- **Status:** per lane: slices complete over total, what runs and for how long, last `Now:` age, waiting merges; the integration HEAD and last gate result.

## Unattended

When the user is away and said to continue: answer lane questions that have a clear default, log the rest in `QUESTIONS.md` with your recommendation, and keep other lanes moving. A provider error (429, 503, capacity, usage limit) across lanes: pause the lanes it hits, keep the others within budget, and tell the user once; there is no fallback model (`agent-run`, Pairing). Report only failures, merges and the end.
