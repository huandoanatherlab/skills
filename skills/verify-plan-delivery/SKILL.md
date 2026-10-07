---
name: verify-plan-delivery
description: Verify that a completed implementation fully satisfies its approved plan. Use after all implementation slices and code-review loops to check acceptance criteria, final integration gates, deletion proof, architecture ownership, plan deviations, and residual failures before reporting delivery complete.
---

# Verify Plan Delivery

Prove the final implementation against the approved plan. This is an acceptance audit, not another general code review. Do not edit files or reinterpret unresolved requirements as complete.

## Inputs

Require:

- approved plan path and review status
- final diff or changed-file list
- slice ledger and per-slice evidence
- review-loop verdicts
- repository verification requirements
- known plan deviations and unrelated dirt

If the plan was never approved, report that as a delivery blocker unless the user explicitly waived plan review.

## Verification Passes

### 1. Slice Completion

For every stable slice ID, verify:

- dependencies completed in valid order
- listed files were created, modified, or deliberately omitted with explanation
- checklist items are implemented
- focused verification evidence exists
- thermal code-review gate completed
- live proof at the slice's level (`smoke`, `story`, `suite`) has evidence, or a user waiver is recorded
- done criteria are observably true

Do not accept a ledger checkbox as evidence by itself.

### 2. Acceptance Criteria

Map every plan-level acceptance criterion to concrete evidence: behavior, test, diagnostic, file state, schema state, or explicit user acceptance. Flag any criterion with no proof or only indirect proof.

### 3. Architecture And Deletion Proof

Confirm the delivered source of truth, ownership, lifecycle, persistence, permission path, and public contracts match the approved target shape.

When the plan requires removal or shrinkage, verify with the named grep, file absence, caller search, line count, or architecture check. A wrapper around the obsolete active path is not deletion.

### 4. Integration And Repository Gates

Run or verify the required final build, typecheck, lint, test, end-to-end, migration, and diagnostic commands proportional to the change. Use the repository's documented commands. Record exact results and separate unrelated pre-existing failures.

### 5. Deviations And Working Tree

Classify every deviation:

- `accepted`: explicitly approved and compatible with the goal
- `benign`: implementation detail that preserves architecture and acceptance criteria
- `blocking`: changes ownership, contract, persistence, permissions, migration policy, or user-visible scope without approval

Inspect the final changed-file set for out-of-scope edits, missing generated artifacts, accidental debug code, and untracked deliverables.

## Verdict Rules

Return `DELIVERY INCOMPLETE` when any of these remains:

- incomplete or unreviewed slice
- a required live proof marked not verified without a user waiver (name the blocker)
- acceptance criterion without direct evidence
- failed required gate not proven unrelated
- blocking deviation
- old path required to be deleted still active
- unresolved architecture or security decision
- plan review stopped with open findings

Return `DELIVERY COMPLETE` only when all required evidence is present. A user-requested early stop is not completion.

## Output

Use [references/delivery-report.md](references/delivery-report.md). Keep the report evidence-focused and name exact commands, paths, slice IDs, deviations, and residual failures.

End with exactly one line:

- `DELIVERY COMPLETE`
- `DELIVERY INCOMPLETE`
