---
name: writing-plans
description: Create an evidence-grounded implementation plan before changing code. Use for features, migrations, refactors, ports, architecture changes, diagnostic work, or any multi-step implementation that needs explicit ownership, slices, verification gates, and an execution handoff.
---

# Writing Plans

Announce: `I'm using the writing-plans skill to create the plan.`

Write a plan that preserves decisions an implementer cannot safely rediscover: the current seam, target owner, source of truth, invariants, implementation slices, deletion requirements, and proof of completion. Default to medium-grained slices rather than a procedural script.

## Output Location

- Use the path requested by the user.
- Otherwise use `.scratch/<feature-name>-plan.md`.
- Use `.scratch/<feature-name>/` when design, inventory, and execution checklists need separate artifacts.

## Choose One Mode

| Mode | Use for | Emphasize |
| --- | --- | --- |
| Design / Port | Replace a subsystem or adapt external behavior | current seam, target flow, source inventory |
| Migration / Refactor | Move ownership, storage, transport, or state | baseline, deletion proof, compatibility gates |
| Implementation | Build behavior whose design is already decided | slices, contracts, tests, done criteria |
| Diagnostic | Investigate an unproven bug or performance cause | hypotheses, probes, evidence gates, rollback |
| Checklist | Produce a compact execution tracker | batches, blockers, acceptance criteria |

Split independent subsystems into separate plans or parallel tracks with non-overlapping file ownership.

## Ground the Plan

Inspect enough code and primary source material to prove:

- where the behavior lives now
- which module or layer should own it afterward
- which existing patterns and contracts to follow
- which runtime and persisted invariants must remain true
- which tests or diagnostics guard the area
- which old concepts must be deleted or explicitly rejected

Do not write a non-trivial plan from the request alone. Link paths and summarize the relevant invariant instead of repeating repository documentation.

For migrations and ports, classify source material:

| Category | Meaning |
| --- | --- |
| Copy / Adapt | Small pure helper or contract worth carrying forward |
| Reference Only | Behavior semantics are useful but the structure is wrong |
| Reject | Architecture, transport, persistence, UI, or compatibility concepts that must not survive |

## Plan Contract

Use the complete artifact contract in [references/plan-contract.md](references/plan-contract.md). Every implementation slice must have a stable ID, dependencies, scope, file map, checklist, verification, and observable done criteria.

Keep most plans within 300-400 lines. If the plan will exceed 500 lines, split design, inventory, execution, or verification into separate artifacts. Prefer boundary shapes over long code samples.

## Architecture Gates

For risky architecture, permissions, persistence, migrations, ports, or large-file refactors, record:

- source of truth and public contract boundary
- runtime versus persisted state
- permission and security path
- lifecycle, reset, reload, teardown, and disposal ownership
- error handling and stale-owner behavior
- compatibility and migration policy
- explicit non-goals
- concepts and paths that must be deleted, not wrapped
- files that must not become catch-all modules

For large-file refactors, require before/after `wc -l`, a named responsibility removed from the old owner, focused tests for the new boundary, and a grep or architecture gate when practical.

## Live Proof

Give every slice a live proof level, decided now so review can challenge it:

- `none`: pure library or internal logic; focused tests prove it.
- `smoke`: internal change; the app must still start and one main flow must work.
- `story`: user-visible behavior; name each behavior to drive like a real user.
- `suite`: the project's existing E2E suite covers it; name the specs.

Name the behaviors, not the tooling: how to run the app belongs to the project config (`.agents/build.md`), not the plan. Tag slices that touch migrations, persistence, permissions, security or a public contract as `risky`.

## Review Gate

After writing the complete plan, run `thermal-review-loop` with `plan-review` as the lens.

- Treat the plan author as the fix owner.
- Provide only the plan, spec or source paths, relevant repository rules, and verification evidence.
- For risky work, run separate thermal loops for both perspectives:
  - direction, product, and runtime fit
  - strict architecture and implementation readiness
- Do not report review complete until each loop satisfies the `thermal-review-loop` done definition.
- If the user stops review early, record `stopped-with-open-findings`; never report the plan as approved.

## Execution Handoff

Finish with:

- plan path
- review status and evidence
- unresolved decisions or deviations
- recommended executor: `build-plan` (it picks `cross` or `inline` mode per slice), or a human checkpoint for unresolved architecture decisions
- required implementation review lens: `code-quality-review`
- final acceptance skill: `verify-plan-delivery`

Do not ask the user to choose an execution mode when they already gave a clear next action.

## Failure Guards

- Do not preserve old architecture merely because it contains useful behavior.
- Do not add compatibility layers unless compatibility is an explicit requirement.
- Do not route new feature logic through a known catch-all module.
- Do not use vague proof such as "tests pass"; name the command, diagnostic, or observable behavior.
- Do not mark a plan approved while blockers or undocumented disagreements remain.
