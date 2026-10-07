---
name: writing-prd
description: Create, review, or update concise product requirements documents in docs/prd, grounded in user intent and existing product behavior. Use for PRD work and product documentation affected by an authorized task.
---

# Writing PRDs

Announce use of this skill. Preserve product intent in concise, traceable requirements without prescribing unnecessary implementation detail.

## Working Policy

- PRDs describe product intent and the scope of a particular feature or version. Out-of-scope items are not permanent prohibitions on future work.
- A current user request can authorize a change to an existing requirement. Update affected documentation within that task; do not request approval again for an already authorized change.
- Draft status, missing independent review, or a feature absent from the PRD does not by itself block design or implementation.
- Ask only when a consequential product choice remains unresolved by the available instructions and evidence. State the affected decision and continue independent work.
- These rules do not override explicit repository approval requirements or authorize actions outside the task.

## Location and Structure

Keep canonical PRDs under `<repo-root>/docs/prd/`, with `README.md` as the index. Follow coherent existing organization; otherwise use [assets/prd-structure.md](assets/prd-structure.md). Create only needed files.

Use [assets/prd-template.md](assets/prd-template.md) for new or substantially restructured documents. Keep a compact core: metadata, problem/outcomes, scope, behavior and acceptance criteria, relevant rules/edge cases, assumptions/questions, and links/history. Preserve coherent headings and metadata in existing documents. Merge or omit optional sections rather than filling them with N/A.

## Ground and Write

1. Read repository instructions, related PRDs/TDDs, and the user request or other product sources.
2. Inspect affected code when current behavior matters. Distinguish observed behavior from desired requirements; label assumptions and unresolved questions.
3. Update the narrowest owning document. Preserve stable requirement IDs and link to sources; the current task can be a source. Do not invent owners, approvals, or success thresholds.
4. Write one primary observable behavior per requirement with testable acceptance criteria. Plain language is the default; EARS, RFC keywords, and Given/When/Then are optional when they improve clarity.
5. Keep architecture choices in the TDD unless they are genuine product constraints. Synchronize affected TDD sections when the change is clear and within task scope; identify any remaining design work precisely.

For requirement conventions and the review checklist, use [references/prd-standard.md](references/prd-standard.md).

## Updates and Versioning

Use the repository convention; otherwise use `MAJOR.MINOR`, starting at `0.1`.

- Bump MINOR for compatible changes to requirements; MAJOR for incompatible changes to product behavior or commitments.
- Editorial, formatting, or link-only edits need only an updated date. Group related edits into one version change and concise history entry.
- Version numbers record change, not approval or permission. Preserve existing versions; do not reset them during restructuring.
- Update indexes when entries change and links when affected. Preserve IDs for the same concepts and do not reuse retired IDs.

## Review and Handoff

Self-review the affected scope by default. Use independent or thermal review when explicitly requested or required by repository instructions; otherwise recommend focused review for unresolved high-impact concerns without inventing a gate.

Check requirement clarity, acceptance criteria, factual grounding, links, and downstream consistency. Distinguish document status, review evidence, and readiness; report only review actually performed.

Finish briefly with paths, material changes, checks performed, and remaining decisions. Use `ready-for-tdd`, `partial`, or `not-ready` when useful, based on substantive gaps in the affected scope. Missing independent approval alone is not a readiness gap; identify exactly which part any unresolved decision prevents.
