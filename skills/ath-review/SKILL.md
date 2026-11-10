---
name: ath-review
description: Get an independent review of a plan, the current branch diff, a commit range or a PR from the read-only ath-reviewer agent, triage its findings, and optionally loop on fixes until it approves. Use when the user asks to review something outside a running ath-execute build ("review", "rà soát", "check lại").
---

# Review

`ath-execute` and `ath-plan` run their own reviews. This skill is for a review the user asks for directly.

## Run it

1. **Target and lens:**
   - a plan or design doc → `plan`;
   - a diff, branch, commit range or PR → `slice`. Use `final` for a whole finished feature checked against its plan.
   - No target given: the current branch against its base (`git merge-base HEAD origin/<default>`).
   - For a PR: `gh pr diff <n>` / `gh pr view <n>`, or check out its head in a worktree.
2. **Spawn** `ath-reviewer`, `name: review-<short target>` (Claude Code: Agent tool, `subagent_type`; elsewhere: `../ath-execute/roles/README.md`). Give it the target, not your opinion:

   ```
   Lens: <plan|slice|final>. Target: <paths, or the diff command, e.g. git diff <base>..HEAD>.
   Acceptance: <the plan's slice or acceptance list, the PR description, or "the change's stated intent">.
   Evidence already run: <command: result, or none>. Known unrelated failures: <list or none>.
   Project rules: <AGENTS.md / CLAUDE.md>.
   ```

3. **Triage** every finding, one line each:
   - **Accept:** bugs a user can hit, data loss, broken contracts, unmet acceptance, violations of the repo's own rules, wrong `file:line` claims.
   - **Reject, with a reason:** machinery the realistic case does not need, implausible edge cases, wider test matrices, copy or DOM-shape tests, anything the plan cut on purpose.
   - Reviewers over-engineer, so never accept a whole round without sorting it.

## Report, or fix

- **Review only** (the default): report in the user's language: verdict, accepted findings (severity, `file:line`, one-line fix), rejected ones with reasons, what the reviewer could not verify.
- **Fix too** (the user asked, or said "sửa luôn"):
  1. Fix the accepted findings: trivial ones yourself; larger ones with an `ath-builder` named `review-fix`, briefed with the findings.
  2. Re-run the relevant checks.
  3. Continue the same reviewer with each finding marked fixed or rejected: "verify only your own findings".

  **Breaker:** at most 3 reviewer turns, or stop sooner if the same finding comes back after a fix. Then hand the open findings to the user with your recommendation.

A user stop is "stopped with open findings", never an approval.
