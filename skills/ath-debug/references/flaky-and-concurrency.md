# Flaky and concurrency debugging

Use this playbook for intermittent tests, races, deadlocks, eventual consistency, or load-sensitive failures.

## Preserve nondeterminism

- Record seeds, timestamps, ordering, worker count, resource limits, and runtime versions.
- Repeat with a bounded loop and retain the first complete failure artifact.
- Avoid adding sleeps as the first response; they often hide the race.
- Compare isolated, serial, parallel, and stressed execution.

## Classify the failure

Look for:

- missing synchronization or readiness checks;
- shared mutable state or incomplete cleanup;
- stale caches or eventual-consistency windows;
- clock, timezone, random seed, or ordering assumptions;
- resource contention, ports, filesystem paths, or rate limits;
- lost events, duplicate delivery, or non-idempotent retries.

## Wait for conditions

Wait for the state or event that matters, with a bounded timeout and a useful timeout error. Use fixed delays only when elapsed time is itself the behavior under test, and document the timing relationship.

## Test a race hypothesis

Widen the suspected window deliberately, add barriers or event tracing, and vary concurrency. A useful experiment should make the failure frequency change predictably.

## Verify

Run enough repetitions to provide confidence, then run the normal suite without diagnostic timing changes. Never equate one passing run with resolution of a flaky failure.

