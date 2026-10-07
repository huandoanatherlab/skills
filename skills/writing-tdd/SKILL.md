---
name: writing-tdd
description: Create, review, or update concise technical design documents in docs/tdd, grounded in product intent, architecture decisions, and code. Use for technical design documentation and design updates within an authorized task.
---

# Writing TDDs

Announce use of this skill. Describe the design, important constraints, and verification clearly enough to implement while leaving routine implementation choices to the coding agent.

## Working Policy

- TDDs are evolving design records. Current implementation, proposed design, and required invariants are distinct; a description of existing code is not automatically a constraint.
- A current user request can authorize a design change. Update affected documentation within that task instead of requesting approval again for an already authorized change.
- Draft status, missing independent review, or a feature absent from the TDD does not by itself block implementation. Non-goals describe this document's scope, not permanent restrictions.
- The agent may choose reversible implementation details within task scope while preserving applicable behavior, contracts, and security/data constraints.
- Ask only when a consequential choice about product behavior, compatibility, security, data, or architecture remains unresolved by the available instructions and evidence. Pause only the dependent work and continue independent work.
- These rules do not override explicit repository approval requirements or authorize actions outside the task.

## Location and Structure

Keep canonical TDDs under `<repo-root>/docs/tdd/`, with `README.md` as the index. Follow coherent existing organization; otherwise use [assets/tdd-structure.md](assets/tdd-structure.md). Link to contracts and ADRs in their existing canonical locations.

Use [assets/tdd-template.md](assets/tdd-template.md) for new or substantially restructured designs. Keep a compact core: metadata, objective/scope, current baseline, design/decisions, affected contracts/data, relevant failure/risk behavior, verification, and links/history. Preserve coherent headings and metadata in existing documents. Merge or omit irrelevant sections.

## Ground and Design

1. Read repository instructions, the request, relevant PRDs/ADRs/TDDs, and affected code or contracts. A missing formal PRD does not prevent design when product intent is clear; record the source and assumptions.
2. Ground current-state claims in primary artifacts. Describe target changes separately.
3. Identify important ownership, interface, data, and failure boundaries for the affected scope. Link to unchanged shared designs rather than repeating them.
4. Separate required invariants (with reasons/sources), the chosen design, and flexible implementation details. Avoid freezing file layouts, helper names, or internal algorithms without a concrete need.
5. Update the narrowest owning design and synchronize affected PRDs or exact contracts when clearly within scope. Verify contract changes according to their format and compatibility rules.

For design conventions and the review checklist, use [references/tdd-standard.md](references/tdd-standard.md).

## Source Ownership and Conflicts

- PRD: product intent and business behavior.
- ADR: architectural decisions and constraints.
- Feature TDD: feature flow and coordination; service TDD: service internals when a separate document is useful.
- Machine-readable schemas/contracts: exact interface shapes; Infrastructure as Code: exact deployment configuration.

Use each artifact for its own domain. When sources disagree, inspect their scope, currency, and the authorized change. Correct stale documentation when the intended resolution is established; record the reason. If a consequential conflict remains unresolved, ask about that decision rather than blocking the whole task. Do not silently redefine product intent from code.

## Updates and Versioning

Use the repository convention; otherwise use `MAJOR.MINOR`, starting at `0.1`.

- Bump MINOR for compatible design changes; MAJOR for changes invalidating existing contract, ownership, persistence, security, or migration assumptions.
- Editorial, formatting, or link-only edits need only an updated date. Group related edits into one version change and concise history entry.
- Version numbers record change, not approval or permission. Preserve existing versions and stable IDs; do not reuse retired IDs.
- Contract versions follow their own compatibility rules. Update indexes and traceability only where affected.

## Review and Handoff

Self-review the affected scope by default. Use independent or thermal review when explicitly requested or required by repository instructions; otherwise recommend focused review for unresolved high-impact concerns without inventing a gate.

Validate links and changed contracts. Run focused tests/schema checks when relevant and available; distinguish checks performed from proposed verification. Documentation-only changes do not require a full application test suite.

Finish briefly with paths, material changes, verification evidence, and remaining decisions or risks. Include implementation slices or execution order only when useful for a larger change; keep detailed task/file checklists in an execution plan.

Use `implementation-ready`, `partial`, or `not-ready` when useful, based on substantive gaps in the affected scope. Missing independent approval alone is not a readiness gap. Identify exactly which work an unresolved decision prevents, and never claim review or approval that did not occur.
