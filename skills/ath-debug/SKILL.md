---
name: ath-debug
description: Find the root cause of a bug, failing test, build or CI failure, regression, flaky behavior, performance problem or production incident with evidence, then fix it behind a failing test. Use instead of guessing at fixes ("lỗi", "bug", "không chạy", "fail", "chậm", "treo").
---

# Debug

Evidence before edits. Use the lightest mode that gives a reliable answer, and stop investigating once a safe, verified fix is in hand. Talk to the user in their language. Diagnose only when they asked only for a diagnosis.

Roles (`ath-builder`, `ath-reviewer`, `ath-scout`): in Claude Code spawn them with the Agent tool (`subagent_type`); elsewhere follow `../ath-execute/roles/README.md`.

## Mode

Say it in one line when you start (`Mode: Quick`) and again if you escalate.

- **Quick:** reproducible, local, a strong error signal. Read the failure and the code around it, test the one likely cause, fix, verify.
- **Deep:** the cause is not obvious after Quick, or the problem is flaky, slow, cross-component, in production, or touches data integrity or security. Run the full loop and keep the log. Read the matching reference:
  - a bad value far from its source: [root-cause-tracing.md](references/root-cause-tracing.md)
  - timing and nondeterminism: [flaky-and-concurrency.md](references/flaky-and-concurrency.md)
  - slowness, memory, resources: [performance.md](references/performance.md)
  - live incidents: [production-debugging.md](references/production-debugging.md)

## The loop

1. **Reproduce.** Capture the exact error, stack, logs, versions and environment, and the smallest failing case. Check what changed recently: commits, dependencies, config, migrations, flags. With no reproduction, add observability or compare a failing run with a healthy one. Do not compensate with confidence.
2. **Pin it with a failing test.** Before any fix, write the narrowest test (or a script under `.tmp/`) that fails for the reported reason, and watch it fail. It becomes the fix's acceptance check. Skip it only for config, infra or live-incident problems where a test would be artificial; say so.
3. **Localize.** Find where behavior first diverges from the expected path; separate the trigger, the defect and the symptom. Ways to do it:
   - A regression with a known good commit: `git bisect run <the failing test>`.
   - Several independent questions ("is the cache key per tenant?", "who writes this field?"): send them to `ath-scout` agents in parallel and keep their conclusions.
4. **Hypothesize and test, one at a time.** State "X causes it because Y; if true, check E gives R". Run the cheapest high-signal experiment: change one variable, keep it reversible, read the result as confirmed, rejected or inconclusive.
5. **Fix** the earliest responsible cause with the smallest change. No unrelated refactors; retries, timeouts and validation only at a boundary where they protect something distinct.
6. **Verify:** the failing test now passes, the original reproduction is gone, nearby tests pass, and the observed behavior is right, not only the exit code.

**Temporary diagnostics** carry the marker `DEBUG(ath)` on the same line, so `git grep -nF 'DEBUG(ath)'` finds them. Remove them before you finish.

## Deep-mode log

Keep `.tmp/debug-<topic>.md` in the worktree (add `.tmp/` to `.git/info/exclude` if it is not ignored). The top holds the current state: symptom, leading hypothesis, next step. Below, one line per experiment:

```
H3 | cache key lacks tenant_id | logged key at boundary | Rejected: key has tenant_id | fails before the cache
```

Read it before each new hypothesis, so you never repeat an experiment and a compacted session can pick up where it was.

## Breakers

- **3 rejected hypotheses:** step back. Recheck the reproduction, hidden state, test validity and the system boundaries. Then report to the user: the log, what is ruled out, and your next experiment.
- **3 failed fixes:** stop fixing. Repeated failures mean the model of the problem is wrong, or the design is. Report the evidence and propose either a deeper investigation or a plan (`ath-plan`).
- **Production:** read-only. Restarts, cache clears, job replays, data fixes, SQL writes, deploys and rollbacks each need the user's explicit yes, every time. A reversible mitigation may come before the diagnosis when delay increases harm; label it and keep the evidence.

## After the fix

- **Large fix** (changes ownership, contracts or persistence, or spans several modules): stop after the diagnosis and hand the root cause to `ath-plan` as evidence.
- **Normal fix:** commit, then run `ath-review` on the diff (lens `slice`) unless the fix is a few obvious lines.
- **A lasting lesson** (a non-obvious invariant, a trap): add it where the next person will look, such as `docs/design/*` or a new ADR via `ath-docs`, or a line in `AGENTS.md`. Never leave it only in chat.
- `git grep -nF 'DEBUG(ath)'` must find nothing.

## Report

Proportional and short: symptom and impact, decisive evidence, root cause (or the leading hypothesis with its confidence), the change, the verification run, remaining risk. With no root cause found, say so plainly and name the next highest-value experiment.
