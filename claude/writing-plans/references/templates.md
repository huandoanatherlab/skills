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
- **Types and generated code:** no `any`, casts or coercions to silence errors; never hand-edit generated files, regenerate them.
- **Gates before you finish:** `<gate commands>` plus your named tests, re-run until they show zero errors. Report done only then, or with a named blocker. A failure that also fails on the base commit is pre-existing: record it, do not fix it.
- **Never run a command in the background** (`&`, `run_in_background`) **or an interactive one** (password prompts, editors, watch modes). Your session ends when you stop replying and background results are lost. Credentials come from the fences.
- **Report** in `<build>/runs/<slice>/report.md`: files changed and why, commit sha, gate and test results, deviations, `## Questions` (or "none"), what to verify live. Evidence files go in `<build>/runs/<slice>/`, never `/tmp`.
```

## briefs/REVIEW.md (per slice: replace `{{SLICE}}`, `{{WT}}`, `{{BASE}}`)

```markdown
Review slice {{SLICE}} of `<plan path>` with the code lens: read `<absolute path to review/references/code.md>` and the Severity and Calibration sections of `<absolute path to review/SKILL.md>` first.

- Diff: `git -C {{WT}} diff {{BASE}}..HEAD` and `git -C {{WT}} log {{BASE}}..HEAD`.
- Implementer report (a claim; check it): `<build>/runs/{{SLICE}}/report.md`.
- Acceptance: the slice's checklist and done criteria in the plan. Evidence already run: `<command: result>`. Known unrelated failures: `<list or none>`.
- Project rules: `<AGENTS.md / CLAUDE.md>`. <one-line calibration from .agents/build.md>

Also check scope: nothing from other slices, nothing outside the plan. Review manually. Do not edit files or spawn subagents. Do not run tests that need a database, network, ports or file writes; judge the evidence given and state what you could not verify. Write plain sentences. End with exactly one line: `APPROVED` or `CHANGES REQUIRED`.
```

Point to the plan by path; never paste slice text. Keep the rendered prompt under about 1.5K characters. Verify rounds use the prompt in `review` step 4.

## TRACKER.md

```markdown
# Build: <topic>

**Plan:** <path>  **Branch:** <branch>  **Base:** <branch>@<sha>  **Worktree:** <path>
**Now:** <current step, live run ids, next action>
**Progress:** <complete>/<total> slices (<n>%), <built but unreviewed>
**Authority:** <what the user allowed>

| Slice | Mode | Builder | Reviewer | State | Round | Commits | Verdict | Live | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

Builder and Reviewer cells: `<model>/<effort> via <t3|host|script>`, plus the task, agent or session id.
States: pending, blocked (name the blocker), building, reviewing, fixing, complete. Round counts reviewer turns on the slice.

## Resources
- <worktree path, branch, database, container or process (pid, port)> — <slice> — <removed?>

## Log
- <time> <event>
```

Update **Now** and **Progress** before every long wait so a fresh session can resume from this file alone. Keep the header short; history goes in Log.
