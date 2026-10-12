# Production debugging

Use this playbook when investigation can affect users, data, availability, security, or compliance.

## Priorities

1. Protect people and data.
2. Contain impact with the safest reversible action.
3. Preserve evidence.
4. Restore service.
5. Diagnose and implement the durable fix.

Containment is not root-cause resolution. Track both separately.

## Safe investigation

- Prefer read-only queries and existing telemetry.
- Bound log volume, query scope, retries, and diagnostic traffic.
- Redact secrets and sensitive data.
- Record timestamps, versions, deployment identifiers, flags, and topology.
- Ask the user before restarting, clearing caches, replaying jobs, modifying data, deploying, or rolling back, unless already granted for this incident. Understand the evidence and consequences first.
- Use canaries, feature flags, staged rollout, or rollback when available.

## Cross-component localization

At each boundary, compare the request or state entering and leaving the component. Verify configuration propagation, version compatibility, identity, timeouts, retries, and ownership of persistence.

Add temporary correlation identifiers or narrow diagnostics only where the signal is missing. Remove them or convert them into intentional telemetry after resolution.

## Verification

Confirm recovery through user-visible behavior and health indicators. Watch for delayed effects, queued work, partial writes, duplicate processing, and recurrence after traffic returns.

Document remaining uncertainty, follow-up prevention, and any containment that still needs removal.
