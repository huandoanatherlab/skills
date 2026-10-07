---
name: writing-specs
description: Write or update a product spec (PRD, what and why) or technical design (TDD, how) in docs/; use for lasting product or design documentation, not for a build plan.
---

# Writing Specs

Two kinds of lasting docs with one workflow:

| Kind | Holds | Location | Template |
| --- | --- | --- | --- |
| PRD | Product intent: problem, outcomes, scope, requirements with acceptance criteria | `docs/prd/` | [assets/prd-template.md](assets/prd-template.md) |
| TDD | Design: baseline, flow, invariants, contracts, failure behavior, verification | `docs/tdd/` | [assets/tdd-template.md](assets/tdd-template.md) |

A build plan (slices, files, checklists) belongs to `writing-plans`, not here. Each folder has a `README.md` index. Follow existing organization when coherent; otherwise start with a README plus one file per feature and add shared files (glossary, business rules, ADRs, service designs) only when reused.

## Policy

- Docs record current intent and evolve with authorized work. A user request can authorize changing a requirement or design; update the docs in that task without asking again.
- Draft status, missing review, or a feature absent from the docs never blocks work by itself. Non-goals scope this version, not the future.
- Ask only about a consequential product, compatibility, security, data or architecture choice the evidence leaves open; state what it blocks and continue the rest.
- Each source owns its domain: PRD product intent, ADR architecture decisions, TDD flow and internals, schemas exact interfaces. When sources disagree, check scope and currency, fix the stale one with a reason, and never redefine product intent from code.
- Repository approval rules still apply.

## Write

1. Read the repo instructions, the request, related PRDs/TDDs/ADRs, and the affected code when current behavior matters.
2. Separate observed behavior from desired behavior; label assumptions and open questions with their impact.
3. Update the narrowest owning document; keep stable IDs and link sources (the current task is a valid source). Never invent owners, approvals or thresholds.
4. **PRD:** one observable behavior per requirement, each with testable acceptance (success and a relevant failure). Plain language by default; MUST only for real obligations; measurable targets only when supported. Keep architecture out unless it is a product constraint.
5. **TDD:** ground the baseline in code. Split required invariants (with their reason), the chosen design, and implementation freedom the builder may decide. Cover only the concerns the design touches: state and consistency, concurrency and idempotency, retry and recovery, security and privacy, telemetry, rollout and rollback, migration, compatibility. Verification names observable outcomes and focused checks, planned separately from executed.
6. Sync the other doc when the change clearly affects it; otherwise name the remaining update.

Merge or omit template sections rather than writing N/A.

## Versions

Use the repo's convention; otherwise `MAJOR.MINOR` from `0.1`. MINOR for compatible changes, MAJOR for changes that break product commitments or contract, ownership, persistence, security or migration assumptions. Editorial edits only update the date. Versions record change, not approval. Never reuse retired IDs; update indexes and links you affect.

## Review and finish

Self-review the changed scope against the steps above: claims grounded, sources traceable, acceptance testable, IDs and links resolve, no status or non-goal acting as an approval gate. Use `review` with the plan lens only when the user or repo asks, or for an unresolved high-impact concern.

Finish with paths, material changes, checks actually run, open decisions, and readiness (`ready`, `partial` with the blocked part, or `not-ready`). Missing independent review alone is not a readiness gap. Never claim a review that did not happen.
