# Root-cause tracing

Use this playbook when the failure appears far from the source of invalid state.

## Trace backward

1. Identify the first observable wrong operation or value.
2. Find the caller or producer that supplied it.
3. Record the value and the invariant it violates.
4. Continue toward the entry point until the value is first created, corrupted, or accepted incorrectly.
5. Distinguish:
   - **trigger:** event or input that exposes the problem;
   - **defect:** behavior that violates the invariant;
   - **symptom:** place where the failure becomes visible.

Fix the defect at the earliest layer that owns the invariant. Add a downstream guard only when it catches a meaningfully different path or prevents a dangerous side effect.

## Improve the signal

When static tracing is insufficient, instrument immediately before the suspicious operation. Capture only relevant context:

- arguments and derived values;
- state or lifecycle phase;
- request, job, or correlation identifier;
- component boundary;
- stack trace when caller identity matters.

Avoid logging secrets, credentials, personal data, or entire payloads by default.

## Locate state pollution

For order-dependent tests or shared-state corruption:

1. Confirm the failure disappears in isolation.
2. Run likely predecessors with the failing test.
3. Bisect the preceding test set or commit range.
4. Inspect global state, environment variables, clocks, caches, databases, files, ports, and mocks.
5. Verify cleanup and ownership rather than merely reordering tests.

## Stop condition

Stop tracing when evidence identifies the earliest responsible owner and an additional step would not change the fix or risk assessment.

