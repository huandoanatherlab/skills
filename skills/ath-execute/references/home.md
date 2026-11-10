# Home: several plans under one index

This session sits on the main branch and coordinates the plans of `00-index.md`.

**Without T3** (no `mcp__t3-code__*` tools), there are no parallel plan threads:
- Run the plans one at a time in this session, in dependency order, directly on the main branch: set each plan's `branch` to the main branch.
- Use the normal slice loop, and skip each plan's own final review.
- After the last plan, run the skill's Finish.

The rest of this file is for T3. In T3 the home thread builds no slices itself. Each plan runs in its own T3 thread on its own worktree and branch, runs the normal slice loop, and reports back here. This thread merges each plan into the main branch, runs the whole-topic finish and opens the one PR.

State: `00-index.progress.json` (`plans`, `fullChecks`, `resources`, `questions`, `log`). Commit it on every change.

## Start (and resume)

Run Start steps 2–7 of the skill against `00-index.progress.json`, which sets `base` and `fullChecks` and pins and renames this thread. Parallel slices do not apply here. On resume, also check every `running` plan's thread with `t3_thread_list`, and its branch tip with `git log`. Then launch.

## Launch plans

After start and after every merge: launch every plan whose `depends` are all `merged`, up to 3 `running` at once.

1. In the plan's progress file, set `home` to this thread's id (`t3_thread_list` → `currentThreadId`) and `branch` to `<main branch>--<NN-area>`. Commit it on the main branch, so the new worktree starts with it.
2. Call `t3_thread_launch`:
   - `title`: `<topic> · <NN-area>`
   - `workspaceStrategy`: `{type: "worktree", baseRef: "<main branch>", branch: "<main branch>--<NN-area>", startFromOrigin: false}`
   - `clientRequestId`: `<topic>-<NN>-launch`. Reuse it on a retry; after an error, check `t3_thread_list` before launching again.
   - `message`: "Load ath-execute and build docs/plans/<topic>/<NN-area>.md. Go is given. Home thread: <id>. Report to home with t3_thread_send (mode queue): `DONE <NN> at <sha>` when finished, `BLOCKED <NN>: <reason>` when nothing can move."
   - model: inherit this thread's.
3. Set the plan `running`, record its thread id, branch and worktree path (from `t3_worktree_list` or `t3_thread_list`) in `plans` and under `resources`, and commit.

## Messages from plan threads

They arrive here as messages sent by an agent, not by the user. Act on them.

**`DONE <NN> at <sha>`:**
1. Check that the sha is the tip of that plan's branch and that its progress file there says `done`. Set the plan `done`.
2. `git merge --no-ff <plan branch>` in this worktree, with message `merge: <NN-area>`. On a conflict, `git merge --abort` and send the plan thread: "Merging into <main branch> conflicts in <files>. Merge <main branch> into your branch, resolve, re-run the affected checks, push, and report DONE again."
3. Run the full checks. On a failure, `git reset --hard ORIG_HEAD` (the merge is not pushed yet) and send the plan thread: "Full checks fail after merging into <main branch>: <check and output>. Merge <main branch> into your branch, reproduce, fix, push, and report DONE again."
   - Count both cases in `mergeAttempts`. **At 2,** set the plan `blocked` and ask the user, with the evidence and your recommendation.
4. On pass:
   - Push and set the plan `merged` with the sha.
   - Settle its thread (`t3_thread_organize settle`).
   - Load `ath-cleanup` in plan mode for its worktree and branch.
   - Tell running plans that share a file listed under Shared files to merge the main branch in.
   - Commit, then launch what can start.
5. Post one line to the user: plan merged, what is next.

**`BLOCKED <NN>: <reason>`:** answer it when the plan or the code settles it; otherwise ask the user, numbered, with your recommendation. Keep the other plans going.

## Status

For "tiến độ", run the skill's `scripts/status` on the main branch and add each running plan thread's status from `t3_thread_list`. A running plan thread that is idle without a DONE or BLOCKED: read its last messages (`t3_thread_read`, small `limit`), and send it "tiếp tục" if it simply stopped.

## Finish

After the last plan merges, run Finish steps 1–8 of the skill on the main branch. The final review covers `<base>..HEAD` against `00-index.md` and every plan file.
