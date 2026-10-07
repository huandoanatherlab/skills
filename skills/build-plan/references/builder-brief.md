# Common builder brief

Copy to `<build dir>/briefs/COMMON.md` and fill every `<…>`. Each slice prompt says "Read briefs/COMMON.md first", then names the slice, its plan section, its named tests and any extra fences.

```markdown
You are the implementer for ONE slice of `<plan path>`.

- **Worktree:** `<absolute worktree path>`. Work and commit only there. Use absolute paths.
- **Read first:** the repo's `AGENTS.md`/`CLAUDE.md`, your slice in the plan, and every design section it cites. Verify each file:line reference against the worktree; line numbers drift.
- **Git:** do not push, rebase or amend earlier commits. One commit for the slice; fixes for review findings are separate commits. Stage files by explicit path. Conventional message.
- **The plan is frozen.** If it is wrong against the real code, implement what is safe and write the problem under `## Questions` in your report. Do not invent a new design.
- **Simplest code that fully meets the slice.** No speculative abstractions, flags or retry machinery. Match the surrounding style and comment density.
- **Tests:** only the tests your slice names, asserting behavior (state, persisted data, ordering, recovery, permission boundaries). Never assert on copy, prompt text, CSS classes or DOM shape.
- **Data:** tests use `<test database or none>`. Never run migrations or whole suites against `<live environment database or none>`.
- **Gates before you finish:** `<project gate commands>` plus your named tests. If a failure also fails on the base commit, record it as pre-existing instead of fixing it.
- **Do not** start dev servers, touch other worktrees or terminal sessions, run live browser checks, or post to real external services (chat, issue trackers, email). The coordinator does live verification.
- **Never run a command in the background** (no trailing `&`, no `run_in_background`, no "I'll wait for it"). Your session ends when you stop replying and a background result is lost. Run every test in the foreground, even long ones.
- **Report** in `<build dir>/runs/<slice>/report.md`:
  - what changed: files, and why;
  - the commit sha;
  - gate and test commands with their results;
  - deviations from the plan, with reasons;
  - `## Questions`, or "none";
  - what the coordinator must verify live.
```
