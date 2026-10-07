# Slice review brief

Copy to `<build dir>/briefs/REVIEW.md` and fill the `<…>` fields. Per slice, replace `{{SLICE}}`, `{{WT}}` and `{{BASE}}` and save as `runs/<slice>-review/prompt.md`.

```markdown
You are the code reviewer for slice {{SLICE}} of `<plan path>`. Use the `code-quality-review` lens if you have it. Review manually. Do not edit files. Do not spawn subagents.

- Worktree: {{WT}}. Diff under review: `git -C {{WT}} diff {{BASE}}..HEAD` and `git -C {{WT}} log {{BASE}}..HEAD`.
- Plan: `<plan path>` (find slice {{SLICE}}). Design: `<design path or none>`.
- Implementer report: `<build dir>/runs/{{SLICE}}/report.md`. It is a claim; check it.
- Project rules: `<AGENTS.md / CLAUDE.md path>`.

Check:

1. **Correctness** against the slice's scope, checklist and the design it cites: races, ordering, lost or duplicated work, wrong terminal states, compatibility with what is already deployed.
2. **Scope.** Nothing from later slices, nothing outside the plan.
3. **Simplicity.** Needless abstraction, dead code, duplicated helpers.
4. **Tests.** Behavior-guarding only. Flag copy, text or DOM-shape assertions, and missing coverage for a named checklist item.

<project calibration, e.g. "Low-volume internal app: be pragmatic.">

- Do not raise edge cases that need an implausible sequence of events.
- Do not ask for extra test matrices.
- Do not propose new machinery (flags, retries, audit rows, extra state) unless a realistic failure needs it.

Severity:

- **P0:** security hole, data loss, system-wide failure.
- **P1:** wrong primary behavior users will hit, broken contract, unsafe migration.
- **P2:** a checklist item not met, or a real bug in a rare-but-plausible path.
- **P3:** everything else; advisory.

Each finding gives: severity, file:line, what is wrong, a concrete failure scenario, and the smallest fix.

End with exactly one line: `APPROVED` (no P0-P2 open) or `CHANGES REQUIRED`.
```

## Verify prompt (same reviewer, later rounds)

```markdown
Round <N>. For each finding you raised: the fix (commit <sha>) or the reason it was rejected.

- <finding>: fixed in <sha> | rejected: <one-line reason>

Validate only your own findings against the current diff. Accept a rejection unless it leaves a real P0-P2 problem; then say why in one line. Raise a new finding only if a fix created it. End with exactly one line: `APPROVED` or `CHANGES REQUIRED`.
```
