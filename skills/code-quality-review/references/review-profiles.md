# Review Profiles

Apply the general review first, then add only the profiles relevant to the changed boundary.

## Frontend

- Check loading, empty, error, retry, disabled, and stale states.
- Verify keyboard access, focus behavior, semantic controls, labels, and reduced-motion behavior.
- Inspect hydration, server/client ownership, data-fetch waterfalls, bundle growth, and avoidable re-renders.
- Run the repository's preferred React or frontend diagnostic when available; treat output as evidence and filter unrelated findings.

## Migration And Persistence

- Verify forward migration, rollback or explicit no-rollback policy, mixed-version behavior, idempotency, and partial failure.
- Confirm runtime and persisted sources of truth cannot diverge silently.
- Check backfills, constraints, defaults, nullability, transaction boundaries, and reload behavior.
- Require deletion or grep proof when old storage or transport paths must disappear.

## Permissions And Security

- Trace authentication and authorization from entry point to protected action.
- Verify deny-by-default behavior and deterministic backstops for untrusted or model-generated output.
- Check secret, tenant, account, and user-data boundaries.
- Inspect error messages and logs for sensitive data exposure.

## Concurrency And Lifecycle

- Check cancellation, retries, duplicate delivery, reentrancy, ordering, and stale-owner behavior.
- Confirm related state changes are atomic or safely recoverable.
- Identify the owner of startup, teardown, reset, reload, disposal, and resource cleanup.

## Large-File Refactor

- Compare before and after line counts.
- Name the responsibility removed from the original file.
- Confirm the new module owns a coherent boundary rather than serving as a pass-through.
- Check that callers no longer route the moved behavior through the old catch-all path.
