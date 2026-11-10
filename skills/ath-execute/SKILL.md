---
name: ath-execute
description: Build an approved plan in this session with a build → check → review loop per slice (builder and reviewer sub-agents, circuit breakers), then final review, docs sync, one PR and cleanup. Also resume, pause or report progress of a build. Use on "làm đi", "chốt", "thực thi", "tiếp tục", "tiến độ", "báo cáo" for a plan in docs/plans/.
---

# Execute

This session is the **coordinator**. It never hands its work to another session because of context length: `<plan>.progress.json` is the source of truth, and auto-compaction keeps the session going. After a compaction, re-read the progress file before acting. Builders write code, the reviewer judges it, and you run the checks, triage, keep progress and talk to the user. Talk to the user in their language, one line per event. Commit the progress file on every state change.

- **A plan file** (`plan.md` or `NN-area.md`): run the loop below.
- **An index** (`00-index.md`): you are the home of several plans; follow [references/home.md](references/home.md).

**Roles:** `ath-builder`, `ath-reviewer`, `ath-scout`, described in [roles/README.md](roles/README.md).
- To spawn one in Claude Code: the Agent tool with `subagent_type`, foreground, with a `name`. To continue one: `SendMessage` to that name.
- Elsewhere: follow the README.

**Scripts:** `scripts/status` lives in this skill's directory (`${CLAUDE_SKILL_DIR}/scripts/status` in Claude Code). Run it by absolute path; it needs `node`.

**In T3** (`mcp__t3-code__*` tools available) a few steps add thread and PR tools. They are marked *T3*, and you skip them elsewhere.

## Start (and resume)

1. **Find the plan:** the path given. For "tiếp tục", run `scripts/status --brief`: it lists only the active progress files whose `branch` is the current branch. An index wins over its plan files.
2. **Check you are on the right branch and tree.** `git branch --show-current` must equal the progress file's `branch`, and the tree must be clean apart from progress files (commit those first). If not, stop and tell the user which branch and checkout the build needs.
3. **`git fetch`.**
   - First start (`state: approved`): set `base` to the current HEAD.
   - Resume: reconcile the progress file with `git log`. A slice whose commits exist but is not marked done gets its checks re-run. Continue from the first unfinished slice and never rebuild finished work.
4. **Full checks**, once: find them and store them as `fullChecks`. Take the `## Checks` section of `docs/repo-structure.md`; otherwise the commands CI runs (`.github/workflows/*`) and the package scripts for lint, typecheck, test and build.
5. **Parallel groups** need sub-agents that each get their own worktree branched from this HEAD.
   - Claude Code: `isolation: "worktree"`, with `worktree.baseRef` set to `"head"` in `~/.claude/settings.json` or the repo's `.claude/settings.json`.
   - Without that, or in a harness with no isolated sub-agents, run every group one slice at a time, and tell the user once.
6. **`.tmp/` must be ignored.** Check with `git check-ignore -q .tmp/x`; if it is not ignored, append `.tmp/` to `$(git rev-parse --git-common-dir)/info/exclude`. Temporary files and evidence go there; cleanup removes it.
7. **Set `state: building` and commit.** *T3:* pin the thread (`t3_thread_organize pin`) and rename it `[<done>/<total>] <topic>` (`t3_thread_update`).

## The slice loop

Take the next group whose dependencies are done. For each slice in it:

**a. Build.** Record the slice's base sha and set it `building`. Spawn `ath-builder` named `<ID>-build`.
- One slice works in this checkout.
- Several slices of one group are spawned together, each isolated in its own worktree.

Brief (keep it short; the builder reads the plan itself):

```
Plan: <abs path>. Slice: <ID>. Worktree: <path>. Base: <slice base sha>.
Fences: <anything beyond the defaults, e.g. test DB name, ports>.
```

**b. Check.** Re-run every command check of the slice yourself, in the checkout that holds the slice's commits. Do the live checks yourself and save the evidence to `.tmp/evidence/`. The builder's report is a claim, not evidence.

When a check fails, send the failing check and its output to `<ID>-build`: "Fix only this, re-run, commit." This costs no reviewer. Then check again.

**c. Review.** Spawn `ath-reviewer` named `<ID>-review`:

```
Lens: slice. Plan: <abs path>, slice <ID>. Diff: <diff command>.
Checks (re-run by the coordinator): <id: pass, …>. Project rules: <AGENTS.md/CLAUDE.md>.
```

The diff command is `git diff <slice base>..HEAD` for a slice built here. For an isolated slice it is `git diff <slice base>...<its branch>`, so other slices of the group stay out.

On `CHANGES REQUIRED`, triage every finding before touching anything:
- **Accept** bugs a user can hit, broken contracts, unmet acceptance, and violations of the repo's rules.
- **Reject**, each with a one-line reason: machinery the realistic case does not need, implausible edge cases, wider test matrices, and anything the plan cut on purpose.
- **P3** never triggers a round. Fix it yourself if trivial, or leave it for the final review.

Then:
1. Send the accepted findings to `<ID>-build`.
2. Run step b again.
3. Send `<ID>-review` each finding marked fixed (with its commit) or rejected (with the reason), and ask it to verify only its own findings.

Both roles keep their context, so these messages stay short.

**d. Done** when every check passes on your re-run, the reviewer says `APPROVED`, and the commits exist.
- An isolated slice is merged into this branch only now (`git merge --no-ff <its branch>`). Re-run its checks on the merge, and record its worktree and branch under `resources`.
- Set the slice `done`, record commits and rounds, append a log line, and commit the progress file (`chore(plan): <ID> done`).
- Push and post one line to the user: the slice, its rounds, what is next. *T3:* rename the thread.

### Circuit breakers

| Breaker | Limit | Then |
| --- | --- | --- |
| Fix rounds per slice (failed checks or accepted findings) | 2 | Slice `blocked` with the reason; continue with slices that do not depend on it |
| No progress | The same check fails, or the same finding returns, after a fix | Block the slice at once; do not spend the remaining rounds |
| Builder runs out of turns or context | Partial result | Split the rest into new slice IDs (`S03a`, `S03b`) in the progress file |
| Plan | 2 slices blocked, or nothing left that can move | `state: blocked`; report to the user with the evidence and your recommendation; stop |
| Provider error (429, overload, usage limit) | 1 retry | Mark the slice `blocked: usage limit` and tell the user in one line. *T3:* if the error gives a reset time, `schedule_task` once at that time, bound to this thread, with "ath-execute resume <plan path>", and list it under `resources` |

A reviewer that insists on a rejected finding twice is a disagreement, not a round: put it to the user with your recommendation.

### Questions

A question never stops work that does not depend on it. Add it to `questions` with the default you will use, and keep going. Ask once, numbered with recommendations, when nothing else can move or at the end. Use a blocking question only when nothing can move.

## Finish

Once every slice is done:

1. **Full checks** (`fullChecks`) on HEAD. A failure is pre-existing only if it also fails on `base`.
2. **Verification** section of the plan: run each item, with evidence to `.tmp/evidence/`.
3. **Final review:** `ath-reviewer` named `final-review`, with "Lens: final. Plan: <path>. Diff: git diff <base>..HEAD. Full checks: <results>." Fix accepted findings with an `ath-builder` named `final-fix`, through the same triage and breakers.

**A plan under an index** stops here:
1. Set `state: done`, commit, push.
2. Report `DONE <NN> at <that sha>` to the home (*T3:* `t3_thread_send` to the home thread, `mode: queue`; elsewhere tell the user), and end.

If the home later reports a merge or check failure:
1. Merge the main branch into yours.
2. Reproduce the failure.
3. Fix it through a builder and re-run the checks.
4. Commit, push, and report DONE again.

**A standalone plan** continues:

4. **Docs sync:** load `ath-docs` and run its sync on this diff and the plan's Decisions. Commit.
5. **Cleanup:** load `ath-cleanup` in run mode. It keeps this checkout and the main branch, which the PR still needs, and marks the progress file's `resources`.
6. **Archive the plan:** set `state: done`, then `mkdir -p docs/plans/archive && git mv docs/plans/<topic> docs/plans/archive/<topic>`. Commit `docs(plan): archive <topic>`.
7. **PR:** push, then `gh pr create --base <base branch> --head <main branch>`. The body covers:
   - what changed and why;
   - the slices and their rounds;
   - the checks run, with results;
   - the decisions and the ADRs written;
   - how to test by hand;
   - known gaps.

   *T3:* `link_pull_request`, then `watch_pull_request`.
8. **Report** to the user in a few lines: the PR link, slices and rounds, anything blocked or skipped, open questions. *T3:* rename the thread `✓ <topic> · PR #<n>`.

**After the PR** (*T3:* when the watch wakes the thread; elsewhere when the user brings it back):
- **Failed checks or review comments:** take all the new items together. Triage them, fix through a builder, have a reviewer check the fix (lens `slice`), and push. At most 2 such rounds per PR; then hand the rest to the user. Ignore bot comments that ask for nothing.
- **Merged:** load `ath-cleanup` in merged mode.

## Status, pause, resume

- **"tiến độ", "báo cáo":** run `scripts/status` and reply with its table in a few lines, plus what is running now.
- **"tạm dừng":** let the running role finish its step, set `state: paused`, commit, and stop. Start nothing new.
- **"tiếp tục":** run Start from step 1.
