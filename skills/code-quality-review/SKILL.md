---
name: code-quality-review
description: Review a code diff, implementation, refactor, migration result, or focused file set for blocking correctness, regression, architecture, maintainability, security, and verification issues. Use as the standard implementation review lens, including inside thermal-review-loop. Do not use for plan documents or whole-repository speculative audits.
---

# Code Quality Review

Review the requested diff or files manually. Treat tests and automated tools as evidence, not verdicts. Do not edit files or spawn subagents while acting as a reviewer inside `thermal-review-loop`.

## Establish Scope

Identify:

- requested behavior and acceptance criteria
- changed files and relevant callers
- public contracts, data boundaries, and owners affected
- verification already run
- known unrelated dirt or failures

Default to the current branch diff only when the caller did not provide a target. Expand scope only far enough to prove a finding or understand a boundary.

Read [references/review-profiles.md](references/review-profiles.md) when the change involves frontend behavior, migrations, persistence, permissions, security, concurrency, or large-file refactors.

## Review Passes

### 1. Correctness

Trace each meaningful behavior through success, empty, error, cancellation, retry, reload, and teardown paths when applicable.

Look for:

- behavior that does not satisfy the request or plan
- lost data, stale state, race conditions, partial updates, and non-atomic transitions
- incorrect default, fallback, error, or compatibility behavior
- contract mismatches across callers and implementations
- validation occurring after a trust boundary instead of before it
- missing handling for existing variants or states

### 2. Ownership And Architecture

Check that logic lives in the canonical owner and that the change reduces or preserves conceptual complexity.

Treat as material findings when the change:

- adds a competing source of truth
- routes domain logic through a shared catch-all module
- moves code without moving ownership
- creates a wrapper, adapter, generic, or interface with no earned boundary
- preserves an obsolete active path that should be deleted
- weakens types through casts, `any`, loose optionality, or silent coercion
- creates lifecycle behavior with no clear owner

### 3. Simplicity And Maintainability

Prefer deletion and canonical reuse over new abstractions. Flag meaningful duplication, unnecessary dependencies, serialized independent work, sprawling conditional modes, and large files that grow without an ownership split.

Do not report style nits or demand abstraction merely to reduce repeated syntax. Recommend the smallest structural fix that removes the problem.

Calibrate to the project. Read its `AGENTS.md`/`CLAUDE.md` and any review calibration in `.agents/build.md`. Do not propose machinery (retries, flags, extra state, audit rows, locks) unless a realistic failure needs it, and do not raise edge cases that need an implausible sequence of events.

### 4. Verification

Check whether tests and diagnostics prove the changed boundary rather than merely execute nearby code.

Require focused evidence for:

- user-visible behavior
- failure and migration paths
- security or permission decisions
- persistence and reload behavior
- deleted or replaced architecture
- concurrency and partial-failure behavior

Run narrow read-only diagnostics when useful and authorized. State commands and results. Never approve solely because existing tests pass.

## Severity

- `P0`: catastrophic security, data loss, or system-wide failure
- `P1`: incorrect primary behavior, serious regression, unsafe migration, or broken contract
- `P2`: material edge-case bug, architectural ownership failure, or maintainability problem likely to cause near-term defects
- `P3`: real but non-blocking issue with limited impact

Use `CHANGES REQUIRED` for any P0-P2 finding. P3 findings may remain advisory when they do not violate acceptance criteria or create material risk.

## Output Contract

Return findings highest severity first. For each finding include:

- severity and concise title
- tight `file:line` reference
- concrete failing scenario or structural defect
- why it matters
- smallest viable fix

Then include:

- verification assessed or run
- confirmed strengths that should not be reworked
- residual unrelated dirt

End with exactly one line:

- `APPROVED` when no blocking or material issue remains.
- `CHANGES REQUIRED` when any P0-P2 finding remains.
