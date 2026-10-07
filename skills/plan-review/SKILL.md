---
name: plan-review
description: Review an implementation plan, design, migration plan, port plan, spec, or `.scratch/*-plan.md` against actual code and primary source material. Use to find false current-state claims, internal contradictions, missing ownership, incomplete slices, unsafe architecture, and acceptance criteria the plan cannot produce. Do not use for code diffs.
---

# Plan Review

Treat a plan as a set of checkable claims, not prose. Ground every finding in artifacts you actually read. Do not edit the plan or spawn subagents when acting as a reviewer inside `thermal-review-loop`.

## Review Order

### 1. Inventory

Read the plan end to end and extract:

- every referenced file and owner
- every current-state and source-material claim
- every decision and invariant
- every implementation slice and dependency
- every slice's live proof level (`none`, `smoke`, `story`, `suite`) and risk tag, and whether the level can actually prove its done criteria
- every acceptance criterion and proof command
- repository rules that constrain implementation

Verify that modify/reference paths exist. Inspect the surrounding directory for participating files omitted from the plan.

### 2. Current State

Read every file the plan proposes to modify, plus the minimum adjacent code needed to verify ownership and flow. Confirm or refute claims about current behavior with `file:line` evidence.

Check:

- actual source of truth and lifecycle owner
- public and internal contract boundaries
- error, teardown, reload, reset, and stale-state paths
- existing tests and diagnostics
- terminology and naming conventions near the proposed changes

### 3. Primary Sources

For a port, parity claim, migration, or spec-driven change, read the primary source instead of trusting the plan summary. Compare contracts, enums, guards, failure behavior, and permission boundaries exactly. Distinguish intentional adaptation from accidental divergence.

### 4. Implementer Simulation

Mentally execute each slice in dependency order using only the written checklist.

For every acceptance criterion, prove that some slice creates the required behavior and evidence. Flag:

- a criterion no checklist implements
- a proof command requiring files, flags, fixtures, or tools no slice creates
- one slice assuming work another slice defers
- unresolved choices left to the implementer
- failure behavior that admits materially different implementations
- a compatibility or migration policy implied but not stated
- a deletion requirement with no grep, line-count, or ownership proof

### 5. Architecture and Naming

Check whether the plan moves behavior to the canonical owner or merely relocates complexity. Flag duplicate vocabularies, near-synonym fields, one-to-one wrapper types, new catch-all modules, and misnomers the touched migration should fix now.

Do not relitigate explicitly resolved decisions. Do verify that every resolved decision reaches the slice bodies and done criteria.

## Calibration

Report only issues that could make the implementation wrong, unsafe, structurally worse, or blocked. Omit style preferences and optional enhancements. A substantial plan normally requires reading multiple referenced files; a review that checks only the document is incomplete.

## Output Contract

Start with a short verdict summary naming the direction, strongest confirmations, and whether implementation can begin.

Then report findings by severity and category. Number each finding and include:

- severity: `P0`, `P1`, `P2`, or `P3`
- plan `file:line`
- supporting code or source `file:line` when applicable
- impact on implementation
- concrete required fix

Separate non-blocking advisory notes from findings. End with exactly one line:

- `APPROVED` when no blocking or material plan issue remains.
- `CHANGES REQUIRED` when any required correction remains.

Never approve because the prose is polished or because another reviewer approved it.
