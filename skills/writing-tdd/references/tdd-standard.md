# TDD Standard

## Organization

Keep `docs/tdd/README.md` as the index. Use one feature design for a small change. Split orchestration and service internals into separate documents only when the system's complexity or reuse warrants it; link to the owning design instead of duplicating decisions.

Keep metadata small: stable document ID, title, status, version, and update date. Link relevant requirements and ADRs when present; record owners when known. Do not require a new PRD or ADR merely to fill metadata.

## Design Detail

Distinguish three categories:

- **Required invariants:** behavior or boundaries that must hold, with a reason/source. Change them when the task authorizes it and account for downstream effects.
- **Chosen design:** the current solution and important trade-offs; may evolve with evidence and authorized work.
- **Implementation freedom:** details the agent can choose, such as internal helpers or file organization, within the stated constraints.

Ground the baseline in code/configuration; do not mistake it for the required target. Describe ownership and exact contract changes where needed. Use repository-native schemas, diagrams, and ADR conventions when they add clarity; do not introduce tools or document layers ceremonially.

Cover concerns affected by the design: state/consistency, concurrency/idempotency, timeout/retry/recovery, security/privacy, telemetry, rollout/rollback, migration, and compatibility. Link unchanged shared policies. Omit irrelevant sections instead of listing N/A. Preserve relevant safety and failure details even in a short document.

Verification should identify observable behavior and focused tests, commands, or evidence. Label planned checks separately from executed results. For large changes, summarize milestones/dependencies or link an execution plan; file-by-file checklists are not required in the TDD.

## Review Checklist

Apply to the changed scope:

- Current-state claims are grounded and distinct from proposed behavior.
- Product sources and relevant architecture decisions are traceable.
- Required invariants have a reason; ordinary design details remain adaptable.
- Affected responsibilities, contracts, data ownership, and transitions are clear.
- Relevant failure/recovery, security, compatibility, and migration concerns are addressed.
- Verification can establish the intended outcome; reported checks were actually run.
- Changed contracts validate where tooling is available; IDs/links resolve.
- Metadata/history reflects meaningful changes under the skill's versioning convention.
- Open decisions identify affected work; stale documents are corrected when the resolution is established.
- Document maturity and review evidence do not create implicit implementation approval gates.

Readiness means the affected work has enough clarity to implement safely. Routine coding choices or missing independent review do not make a design unready; unresolved consequential decisions may limit only the dependent part.
