# Build templates

Copy into `build/` and fill every `<…>`. Keep them short; project rules live in `AGENTS.md`/`CLAUDE.md` and `.agents/build.md`, so point to them instead of copying.

## briefs/COMMON.md (every builder)

```markdown
You are the implementer for ONE slice of `<plan path>`.

- **Worktree:** `<absolute path>`. Work and commit only there; use absolute paths.
- **Read first:** `<AGENTS.md / CLAUDE.md>`, your slice in the plan, and the design it cites. Verify file:line references; they drift.
- **Git:** no push, rebase or amend. One commit for the slice, one per fix round, staged by explicit path, conventional message.
- **The plan is frozen.** If it is wrong against the real code, do what is safe and write the problem under `## Questions`.
- **Simplest code that fully meets the slice.** No speculative abstractions, flags or retries. Match the surrounding style.
- **Tests:** only the ones your slice names, asserting behavior. Never assert on copy, prompt text, CSS classes or DOM shape.
- **Fences:** <test database; databases, sessions and services you must not touch>. No dev servers, live browser checks or posts to real external services.
- **Gates before you finish:** `<gate commands>` plus your named tests. A failure that also fails on the base commit is pre-existing: record it, do not fix it.
- **Never run a command in the background** (`&`, `run_in_background`). Your session ends when you stop replying and background results are lost.
- **Report** in `<build>/runs/<slice>/report.md`: files changed and why, commit sha, gate and test results, deviations, `## Questions` (or "none"), what to verify live.
```

## briefs/REVIEW.md (per slice: replace `{{SLICE}}`, `{{WT}}`, `{{BASE}}`)

```markdown
Review slice {{SLICE}} of `<plan path>` with the `code-quality-review` lens if you have it. Review manually. Do not edit files or spawn subagents.

- Diff: `git -C {{WT}} diff {{BASE}}..HEAD` and `git -C {{WT}} log {{BASE}}..HEAD`.
- Implementer report (a claim; check it): `<build>/runs/{{SLICE}}/report.md`.
- Project rules: `<AGENTS.md / CLAUDE.md>`. <one-line calibration from .agents/build.md>

Check correctness against the slice's checklist and cited design, scope (nothing from other slices), simplicity, and behavior-guarding tests. Do not raise implausible edge cases, wider test matrices, or machinery a realistic failure does not need.

Severity: P0 security or data loss; P1 wrong primary behavior or broken contract; P2 unmet checklist item or real bug on a plausible path; P3 advisory.
Each finding: severity, file:line, what is wrong, failure scenario, smallest fix.
End with exactly one line: `APPROVED` (no P0-P2 open) or `CHANGES REQUIRED`.
```

## Verify prompt (same reviewer)

```markdown
Round <N>. Your findings:
- <finding>: fixed in <sha> | rejected: <one-line reason>

Validate only your own findings against the current diff. Accept a rejection unless it leaves a real P0-P2 problem. Raise a new finding only if a fix created it. End with exactly one line: `APPROVED` or `CHANGES REQUIRED`.
```

## TRACKER.md

```markdown
# Build: <topic>

**Plan:** <path>  **Branch:** <branch>  **Base:** <sha>  **Worktree:** <path>
**Now:** <current step and what is running>
**Authority:** <what the user allowed>

| Slice | Mode | Builder | Reviewer | State | Commits | Verdict | Live | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

States: pending, blocked (name the blocker), building, reviewing, fixing, complete.

## Log
- <time> <event>
```

Update **Now** before every long wait so a fresh session can resume from this file alone.
