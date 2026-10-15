---
name: systematic-debugging
description: Diagnose bugs, test failures, build or CI failures, regressions, flaky behavior, performance problems, integration issues, and unexpected technical behavior using an evidence-driven workflow. Use when you need to investigate, explain, or fix an issue while avoiding speculative edits, shotgun changes, and unnecessary process overhead.
---

# Systematic Debugging

Use the lightest workflow that can produce a reliable conclusion. Keep the scientific core of debugging without turning it into ceremony.

## Operating rules

1. Respect the requested scope. Diagnose without editing when the user asks only for analysis; implement when the user asks for a fix.
2. Separate observations, hypotheses, and conclusions. Do not present an untested guess as the root cause.
3. Gather enough evidence to choose the next action. When a small, reversible experiment can settle a question, run it instead of seeking certainty.
4. Change one causal variable at a time whenever practical.
5. Fix the earliest responsible cause. Add symptom handling only when it is also operationally necessary.
6. Verify the original failure and relevant regressions before claiming success.
7. Ask before any state-changing action on shared or production systems (restart, cache clear, job replay, data fix, deploy, rollback), unless the user already granted it for this issue.

## Choose a mode

Name the mode in one line when you start (`Mode: Standard, cause not yet shown`) and again when you escalate.

- **Quick:** a localized, reproducible, low-risk issue with a strong error signal. Read the failure and the relevant code, test the one likely cause with a single focused check, then fix and verify.
- **Standard:** the default when the cause is not yet shown. Run the full core workflow.
- **Deep:** production incidents, security or data-integrity risks, flaky behavior, performance problems, cross-component failures, or repeated failed attempts. Run the full workflow, preserve evidence before changing state, keep a log, and read the matching reference:
  - bad values or control flow far from the symptom: [root-cause-tracing.md](references/root-cause-tracing.md)
  - timing and nondeterminism: [flaky-and-concurrency.md](references/flaky-and-concurrency.md)
  - slowness, memory or resource use: [performance.md](references/performance.md)
  - live incidents: [production-debugging.md](references/production-debugging.md)

### Deep-mode log

Keep `<scratch>/debug-<topic>/LOG.md` (scratch dir as in `writing-plans`, default `.scratch/`, git-ignored). The top holds the current state: symptom, mode, leading hypothesis, next step. Below it, one line per experiment:

```text
H3 | cache key lacks tenant_id | check: log key at boundary | Rejected: key has tenant_id | learned: fails before the cache
```

Read the log before each new hypothesis so you never repeat an experiment, and so a fresh session can resume.

## Core workflow

### 1. Triage

Identify expected versus actual behavior, impact and urgency, whether it reproduces, the smallest known failing case, and whether containment is needed.

For an active incident, a reversible mitigation may come before diagnosis when delay increases harm. Label it containment, preserve evidence, and keep investigating.

### 2. Establish the baseline

Capture the exact error, stack trace, logs, exit code, environment, and versions. Run the smallest reliable reproduction when safe.

Check recent changes: history, dependencies, configuration, migrations, feature flags, environment differences, generated artifacts.

Without a reproduction, improve observability or compare failing and healthy runs. Do not make up for it with more confidence in a guess.

### 3. Localize the failure

Find where behavior first diverges from the expected path: compare working and failing cases, follow the bad value or side effect backward, and inspect inputs, outputs, configuration and state ownership at component boundaries. Distinguish the trigger, the defect, and the visible symptom.

Stop when evidence supports the earliest responsible behavior and fixing it is in scope.

### 4. Form a hypothesis

State one falsifiable hypothesis:

> X causes the failure because evidence Y shows divergence Z. If true, check E should produce result R.

Rank hypotheses by explanatory power, evidence, test cost, and risk. Start with the cheapest high-signal test, not the easiest edit.

### 5. Run a minimal experiment

Use the smallest safe intervention: log a boundary value, run a focused test, swap one input or environment variable, disable one component, or bisect history. Prefer read-only checks; keep any mutation reversible and free of cleanup or refactoring.

Read the result explicitly:

- **Confirmed:** go to the fix.
- **Rejected:** record what you learned and form a new hypothesis.
- **Inconclusive:** improve the signal instead of stacking changes.

After three rejected hypotheses, recheck the reproduction, hidden state, test validity, and system boundaries. In Deep mode, also report to the user with the log and your proposed next experiment, and consider a second opinion (Hand-offs).

### 6. Implement the fix

Write the regression test first and watch it fail for the reason you diagnosed; then fix and watch it pass. A test that never failed proves nothing. Skip the test only for configuration, infrastructure, external-service or live-incident issues where it would be artificial or unsafe, and say so; use a focused reproduction script instead.

- Make the smallest maintainable change at the confirmed cause, with no unrelated refactoring.
- Add validation, retries, timeouts, or fallbacks only at boundaries where they give distinct protection.
- Remove temporary diagnostics unless they have lasting operational value.

### 7. Verify

1. Re-run the original reproduction.
2. Run the closest relevant tests, then broader checks in proportion to risk.
3. Confirm the observed behavior, not only a successful exit code.
4. Confirm containment and temporary changes are removed or documented.

If verification fails, go back to localization with the new evidence. Do not layer another speculative fix on top.

## Hand-offs

- **Large fix** (changes ownership, contracts, persistence, or spans several modules): stop after diagnosis and plan it with `writing-plans`, using the root cause as evidence.
- **After a Standard or Deep fix:** run `review` with the code lens on the diff.
- **Second opinion:** after three rejected hypotheses in Deep mode, launch a fresh Opus 5.5 run at high through `agent-run`. Give it the symptom, evidence and log, not your conclusions.
- **Side work:** send lookups to Haiku and code mapping or long bisects to Sonnet at low effort, through `agent-run`.

## Special outcomes

- **External cause:** document the verified boundary, improve the error message or observability, add a bounded retry, timeout or health check where it helps, and state what stays outside local control.
- **Uncertain root cause:** do not invent certainty. Report the leading hypothesis, supporting and conflicting evidence, checks done, and the next highest-value experiment.
- **Several causes:** separate necessary causes, contributing conditions, and amplifiers. Fix them in causal order and verify each when possible.

## Avoid

- Editing before reading the actual failure.
- Changing several variables at once and learning nothing.
- Treating correlation with a recent change as proof.
- Fixing where the error surfaces when bad state originates upstream.
- Repeating an experiment with cosmetic variations.
- Adding validation, retries, or logging at every layer without a distinct purpose.
- Claiming success from code inspection alone.
- Investigating further once evidence supports a safe, verified fix.

## Report

Keep it proportional: symptom and impact, decisive evidence, root cause or confidence-qualified hypothesis, change made, verification run, and remaining risk or next experiment.
