---
name: lane-build
description: Build an approved plan slice by slice as coordinator in this thread, as a lane of a master build or solo; also pause, resume or report it. Use when a T3 thread is told to build, execute or "thực thi / triển khai" an approved plan or a lane.
---

# Lane Build

T3 Code only: without `mcp__t3-code__*` tools, say this skill runs in T3 and stop.

You are the **coordinator** of one plan. Builders write and commit code, reviewers check it, you triage, verify and report. You never review your own code. Run state lives in the **state dir**, written `<state>` below: `<scratch>/<topic>/build/` solo, or the `<NN-area>/` dir a lane's launch message names, so any thread can resume it. A lane never writes the master's files one level up. Launch every builder and reviewer as `agent-run` says; models by job are there too.

Talk to the user in their language. Reports and questions are short: decisions first, numbered questions with your recommendation, bullets, no narrative.

## Two ways to run

- **Lane:** a master thread launched you (`orchestrate`). T3 already bound this thread to the lane worktree and branch. The launch message and `LANE-BRIEF.md` give the master threadId, lane plan, state dir, ports, database, build dir, run budget and what you wait for and feed. The brief overrides the defaults below where they differ.
- **Solo:** the user's own thread builds one plan. Move this thread into a new worktree first with `t3_worktree_handoff` (`branch: feat/<topic>`, `baseRef: <base>`), unless the user says to work in the current checkout or the thread already sits in a worktree. The handoff ends the turn: make it the last call and pass `continuationPrompt: "Continue lane-build Start for <plan path>"`. Children launched with `isolation: shared` then work in that worktree.

### Lane rules

- Push the lane branch after every commit, so nothing is lost if a worktree goes.
- Never merge into the integration or base branch; the master merges.
- Tell the master with `t3_thread_send` (`mode: queue`) to its threadId, one line each:
  - `MERGE-READY <slice> at <sha>` when a slice the plan marks as a merge point, or one another lane waits for, is complete;
  - `BLOCKED <slice>: <reason>` when nothing in the lane can move;
  - `DONE <lane> at <sha>, report <path>` when the lane is finished, after a `MERGE-READY <last slice> at <sha>` for the final pushed sha (whole-lane review fixes included).
- On a master message to merge the integration branch in: merge it, resolve conflicts, re-run the affected slice's review if the resolution changed its code, push, and post MERGE-READY again.
- Keep `Now:` in `TRACKER.md` current; the master's health check reads it. Never edit the master's files or another lane's state.
- Stay inside your budget share. No schedule of your own: the master's health check pings you if a wake-up is lost.

## Start

Requires a plan with Review Status `approved` and no open architecture decision. Read `.agents/build.md` ([references/project.md](references/project.md)); if it is missing, derive it from `AGENTS.md`/`CLAUDE.md` and the repo, and write it once the user approves. Lasting build rules the user gives ("remember to…", gates, roles, fences) go into that file, never host memory.

1. Show one table: plan, role (lane or solo), base and HEAD, worktree, dirty files, environment, roles with model and effort (flag any role in `.agents/build.md` that differs from the `agent-run` defaults and ask whether to keep it), slice order and parallel groups. Wait for "go" unless already given (a lane launch message is the go).
2. `git fetch`, then re-check the plan's file and line references against the branch you build on.
3. In the state dir, write `TRACKER.md`, `QUESTIONS.md`, `briefs/COMMON.md` and `briefs/REVIEW.md` from [references/templates.md](references/templates.md), filled with the project's gates and fences.
4. Sequential slices share this thread's worktree. A slice that runs in parallel with another gets a builder with `isolation: worktree` (`agent-run`). Log every worktree, branch, database, container, image tag prefix, build-output dir, schedule and long-running process you create under Resources in `TRACKER.md`.
5. Start the environment the live checks need, if any, on your own ports.
6. Solo only: create one interval `schedule_task` bound to this thread (every 20 minutes: "check task_status of live runs in TRACKER.md and continue"), list it under Resources, and delete it at Finish, pause or handoff.

Choose a mode per slice:

- **cross** (default): Sonnet 5.5 builder at medium (Opus 5.5 for a heavy slice) and a reviewer by tier (Haiku 5.5, or Opus 5.5 at medium or high, per `agent-run` Models), each a separate run.
- **inline**: tiny or tightly coupled slices sharing files. You build and commit; the reviewer is still a separate run, never you.

The roles in `.agents/build.md` override these defaults; the user's current message overrides both.

**Small build:** a solo plan of one or two `normal`-risk slices built inline skips the Finish whole-diff review and delivery audit; `TRACKER.md` keeps only its header and slice table, and the report goes in your final message. Never skipped: a plan with Review Status `approved` before the first code edit (a pending verify round is not approval), `triage-N.md`, and a separate reviewer run.

## Each slice

1. **Build.** Write `<state>/runs/<slice>/prompt.md` ("Read briefs/COMMON.md first", slice ID, named tests, extra fences), then launch the builder with it. Before any launch, check `TRACKER.md` and `task_status` so the slice has no live run already. Log the `taskId` in `TRACKER.md`, and write the next slice's prompt while it runs.
2. **Check the claim.** Read the whole diff and re-run the slice's named tests and focused gates. A builder's report is a claim, not evidence. If the builder exited without committing (usually a forbidden background job), launch a fix run with the rule restated. A failure is pre-existing only if the same test fails on the base commit.
3. **Review** with the `review` loop, code lens: confirm `git diff --stat <base>..HEAD` is not empty, render `briefs/REVIEW.md` into `<state>/runs/<slice>-review/prompt.md`, launch the reviewer with it at the tier's model and effort, and follow `review` for triage and same-reviewer validation. You are the fix owner: accepted fixes go to a fix run with the builder's model and the findings (`agent-run`, Follow-up).
4. **Live proof** at the slice's level ([references/project.md](references/project.md)), between builds, never while a builder edits a watched dev server.
5. **Record** commits, round count, verdict and evidence in `TRACKER.md`; a lane pushes and posts MERGE-READY when the slice is a merge point. When the user is present, post one line (slice, verdict, what is next).
6. **Context checkpoint.** Check your context size. Above about 200K tokens, pause (below) and hand off now instead of starting the next slice.
7. Launch the next slice at once; answering a question mid-run never ends the turn. A question of yours never blocks work that does not depend on it: ask in plain text or log it in `QUESTIONS.md` with your recommended default, keep processing finished runs and launching independent slices, and use a blocking question tool only when nothing else can move.

A slice is done when its review loop is complete, its live proof passed, and its commits are in `TRACKER.md`.

**Too big:** a builder run well past the plan's 90-minute target (about 2 hours), a builder that stopped at its context limit, or a review with more than 5 P0-P2 findings, means the slice is too big. Stop it at a commit and split the rest into sub-slices with their own IDs in `TRACKER.md`, in parallel where files allow. Check a builder once at about 90 minutes (`task_status`) so this rule is applied while it still saves time.

Run slices in parallel only when files, state and contracts do not overlap: one checkout each (and one database each when tests write data), within the run budget: at most 3 builders and 6 agent runs at once solo, or your share of them as a lane. Merge a parallel child's branch into your branch when its review passes, run focused gates, then remove that child's checkout and branch by exact path and record it.

**When reality disagrees with the plan:** a small detail that keeps architecture and acceptance criteria goes in `TRACKER.md`. A change to ownership, contracts, persistence, permissions, migrations or user-visible scope stops the build: update the plan, re-run its review, then continue. A lane also tells the master, since the change may reach other lanes.

## Keep it cheap

- **Small edits are yours.** Copy, spacing, P3 findings and fixes under about 20 lines: edit and commit them yourself. A builder run costs a fresh context, a review and a wait. They are reviewed with the slice's next round or the whole-diff review.
- **Helpers by job.** Lookups, code mapping and long live-test plans go to the cheapest model that does the job (`agent-run`, Models), not to a builder or to you.
- **Tiered gates.** Fix rounds run focused checks on the changed area; the full gates run at Finish (and, for a lane, by the master at each merge).
- **One piece of work per thread.** Every turn re-reads the whole thread; the context checkpoint enforces the handoff.

## Finish

Solo runs all steps. A lane runs steps 1-3 and 5, then stops: the master runs the delivery audit, ship and final sweep for the whole build.

1. **Whole-diff review** with `review`, code lens, by a fresh reviewer: dead code, duplicated helpers, oversized files, slice IDs in comments.
2. **Gates** from `.agents/build.md`; classify each failure against the base commit.
3. **Live check** of every `smoke`/`story`/`suite` slice end to end, evidence in `<state>/evidence/`.
4. **Acceptance audit** with `review`, delivery lens, by a fresh Opus 5.5 reviewer at high; fix what it finds and repeat that slice's review.
5. **Report** in `<state>/FINAL-REPORT.md`: commit range and deploy order, migration commands per environment, slices with models, verdicts, rejected findings with reasons, deviations, live results with evidence paths, failed or skipped gates, a short manual QA guide, open questions, delivery verdict (solo). Never hide a failure behind "tests pass". A lane then stops its processes and dev servers, cancels its live tasks, removes its own parallel-child checkouts, and posts `DONE` to the master; the master removes the lane worktree.
6. **Ship** per `.agents/build.md` Git: commit any leftovers in logical groups, push and open a PR to the base branch with the report summary and evidence images (`link_pull_request`), or merge if that is the project's flow. Without a Git section or prior authority, ask once.
7. **Clean up** everything under Resources in `TRACKER.md`, one listed path at a time, never a glob over a shared root: stop dev servers, browsers and processes you started; cancel live T3 tasks; delete your schedule; drop temporary databases, containers and the images you built (then `docker builder prune -f`); remove merged worktrees and branches (including `t3/*` branches of `isolation: worktree` children), build output and unused volumes; in `<scratch>/<topic>` keep the plan and `<state>/FINAL-REPORT.md`. Before removing a worktree, check `t3_worktree_list` and `git worktree list`; if another thread is bound to it, stop or settle that thread first (an idle thread's shell can still hold the directory). On `Directory not empty`, `busy` or `Permission denied`, find and stop the holder instead of retrying the delete. Never touch a worktree, branch or process another thread or build owns. List anything kept in the report.

## Pause, resume, status

- **Pause** ("tạm dừng", handoff, the context checkpoint): stop builders at a commit, let read-only reviewers finish and list their task ids under live runs so resume picks up the result instead of relaunching, delete a solo schedule, then update the top of `TRACKER.md` (Now, Progress, live runs, next action) so a fresh thread needs nothing else.
- **Handoff:** after pausing, launch the successor yourself with `t3_thread_launch` (`workspaceStrategy: {type: existing_worktree, worktreePath: <this worktree>, branch: <this branch>}`, the same model) and the message "Resume `<TRACKER path>` with lane-build". A lane tells the master the new threadId. Then stop.
- **Resume** ("tiếp tục", a new thread): read the `TRACKER.md` named in the message, or find the newest `<scratch>/*/build/**/TRACKER.md` in the main checkout whose `**Role:**` is `solo` or `lane` (a `master` tracker belongs to `orchestrate`). Reconcile it with `git worktree list`, branches, `task_status` and commits on the branch; fix the tracker where it is stale. Solo: re-create the interval schedule if runs are in flight. Report progress in one line, then continue from Now without relaunching anything that is still running.
- **Status** ("tiến độ", "bao nhiêu %"): slices complete over total and percent, slices built but not reviewed, what is running and for how long, other plans under `<scratch>/`.

## Unattended

When the user is away and said to continue: fix bugs, log clear-value design changes, cut machinery, and put everything else in `QUESTIONS.md` with your recommendation. A provider error (429, 503, capacity, usage limit) gets one retry on the same model; then that slice waits in `QUESTIONS.md` and you keep going with the others (`agent-run`, Pairing: no fallback model). Check-ins are one line: what runs, which model, how long, where the evidence is. Report only failures and the end, not "still running".
