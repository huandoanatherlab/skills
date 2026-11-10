---
name: ath-cleanup
description: Remove everything a build or debug session left behind (worktrees, merged branches, processes, containers, temp dirs, schedules, debug lines, finished worker threads), exactly and verifiably, then report what was removed and what was kept. Runs at the end of ath-execute and after its PR merges; also when the user says "dọn dẹp", "cleanup", "rà soát và dọn".
---

# Cleanup

Cleanup is a list of exact items, removed one at a time with `scripts/cleanup`, then a second scan that proves nothing is left. The script lives in this skill's directory (`${CLAUDE_SKILL_DIR}/scripts/cleanup` in Claude Code); run it by absolute path, written `cleanup` below. It needs bash, git and, for the process scan, `lsof`. Steps marked *T3* apply only when `mcp__t3-code__*` tools exist. Never `rm -rf` a shared root, never glob, never `pkill -f`/`killall`, never touch what another running build owns.

## Modes

- **run** (end of `ath-execute`): everything this build created, except this thread's own worktree and the main branch, which the PR still needs.
- **merged** (the PR merged): the PR watch (*T3:* `unwatch_pull_request`), the main branch (local, plus remote if GitHub did not delete it), and last of all this thread's own worktree.
- **plan** (the home closes a merged plan of an index): that plan's thread, worktree and branch, local and remote.
- **sweep** (the user asks): leftovers of any finished build in this repo. Show the list and get a yes before removing.

## Steps

1. **Collect the list.** Sources:
   - the `resources` of the progress file(s);
   - `cleanup scan --topic <topic> --into <main branch>`, which lists worktrees with merged/dirty/process flags, merged branches (`<topic>`, `t3/*`, `worktree-*`), processes inside worktrees, `<topic>` containers and `DEBUG(ath)` lines;
   - *T3:* `list_scheduled_tasks` for schedules bound to this run, and `t3_thread_list` for this run's plan threads and idle sub-agent threads that are still unsettled.

   Keep only items this run owns: listed in its resources, named after its topic, or branched from its main branch. Anything else, leave alone and mention it.
2. **Code first.** `cleanup markers`: any `DEBUG(ath)` line left is removed and committed (`chore: remove debug output`) before anything else. Stray files the build created outside `.tmp/` (`git status --short`) are deleted or committed, never left.
3. **Threads** (*T3*). Settle the plan threads and finished sub-agent threads this run created (`t3_thread_organize settle`). A thread bound to a worktree you are about to remove is settled first, because an idle thread's shell can still hold the directory.
4. **Processes and services.** Stop dev servers, watchers and browsers this run started, by the pid or port in its resources; then `cleanup container <name>` for each container, and drop the temporary databases and images listed under resources.
5. **Worktrees** other than your own: `cleanup worktree <exact path>` for each. If it reports holders, check what they are first.
   - `--kill-holders` only for processes this run started, or for the Claude process of a plan thread you already settled.
   - `--force` only to throw away work the run already merged or abandoned.
   - Never retry in a loop.
6. **Branches:** `cleanup branch <name> --into <branch it was merged into>`: builder branches into the plan branch, plan branches into the main branch. Add `--remote` for branches this run pushed.
   - `--force` only with the user's agreement, or for the main branch in step 9.
7. **Schedules** this run created (*T3*): `delete_scheduled_task`.
8. **Verify.** Run `cleanup scan` again; the run's items must be gone. Fix what is left once, or report it.
9. **Your own worktree and the main branch** (merged mode only), as the very last command of the turn:
   1. Confirm `gh pr view <n> --json state` says `MERGED`. A squash merge is not an ancestor, so this replaces the merge check.
   2. Post the report first, because this thread's checkout disappears.
   3. Run one command:

      `cd <main checkout> && <cleanup> worktree <this worktree> --self && <cleanup> branch <main branch> --force --remote`

      `--self` leaves this session's own processes alone.
   4. *T3:* settle this thread (`t3_thread_organize settle`); it applies at the end of the turn.
   On the main checkout itself (no worktree): `git switch <base> && git pull`, then delete the branch the same way.

## Report

Two short lists in the user's language:
- **Removed:** worktrees, branches, processes, containers, threads, schedules.
- **Kept, with why:** for example "worktree feat/x, PR #42 open", or "container y belongs to another build".

Set `"removed": true` on the progress file's `resources` entries you removed, while the file still exists (run mode runs before the plan is archived).
