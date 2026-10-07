---
name: review
description: Independently review a plan, a code change, or a finished delivery and loop on fixes until the reviewer approves; use for any review gate, with a plan, code or delivery lens.
---

# Review

One loop, three lenses. The loop owns the reviewer's lifecycle, triage, fixes and the stop rule; the lens owns what counts as a finding.

| Lens | Target | File | Verdict line |
| --- | --- | --- | --- |
| plan | A plan, design or spec, checked against real code | [references/plan.md](references/plan.md) | `APPROVED` / `CHANGES REQUIRED` |
| code | A diff or file set | [references/code.md](references/code.md) | `APPROVED` / `CHANGES REQUIRED` |
| delivery | A finished build against its approved plan | [references/delivery.md](references/delivery.md) | `DELIVERY COMPLETE` / `DELIVERY INCOMPLETE` |

When you are asked to review directly (you are the reviewer), read the lens file and follow it; skip the loop.

## The loop

**Inputs:** target and paths, lens, acceptance criteria, fix owner, evidence already run, known unrelated failures, and risk (`risky` as defined in `writing-plans` references/plan-contract.md).

**Reviewer:** from the other model family than the author, run with `agent-run start <run-dir> <family> reviewer`. Use a native subagent only when the other family is down, and say so. Its prompt is self-contained, never your session history or conclusions:

```text
Review <target> with the <lens> lens: read <absolute path to the lens file> first.
Acceptance criteria: <list>. Files: <paths>. Project rules: <AGENTS.md / CLAUDE.md>.
Evidence already run: <command: result>. Known unrelated failures: <list or none>.
Review manually. Do not edit files. Do not spawn subagents.
Each finding: severity P0-P3, file:line, what is wrong, failure scenario, smallest fix.
End with exactly one verdict line.
```

1. Start the reviewer. If its report lacks the lens's verdict line, resume it and ask again before acting.
2. On a failing verdict, **triage** every finding into `triage-N.md` before touching anything, one line each:
   - Accept: bugs a user can hit, data loss, broken contracts, type errors, wrong file/line claims, unmet acceptance criteria, violations of the project's own rules.
   - Reject: machinery the realistic case does not need (retries, flags, extra state, audit rows, locks), edge cases needing an implausible sequence, wider test matrices, copy or DOM-shape tests, anything the plan cut on purpose.
3. The fix owner fixes accepted findings and runs focused verification.
4. Resume the **same** reviewer (`agent-run resume`) with every finding and its fix or rejection reason: "Validate only your own findings. Accept a rejection unless it leaves a real P0-P2 problem. Raise a new finding only if a fix created it."
5. Repeat until it passes.
6. For a `risky` target or the final whole-diff review of a build, start one **fresh** reviewer with a complete prompt. Its first-pass approval closes the loop; otherwise it owns its new findings and the loop repeats from step 2.

**Done** when the owning reviewer passes its own findings (a rejection the user accepted counts as closed), plus a fresh first-pass approval when step 6 applies. No further clean-pass rounds.

**Escalate** instead of looping: a reviewer insists on a rejected finding twice, three verify rounds pass without approval, or a reviewer fails three times (then replace it, hand over the old findings, and never claim it approved). Ask the user, or log it in `QUESTIONS.md` when unattended.

A user stop is `stopped-with-open-findings`, never approval.

**Report:** lens, reviewer models and run dirs, rounds, accepted and rejected findings with reasons, replacements, evidence, final state.

## Severity (all lenses)

- **P0:** security hole, data loss, system-wide failure.
- **P1:** wrong primary behavior, broken contract, unsafe migration.
- **P2:** unmet checklist or acceptance item, a real bug on a plausible path, an ownership failure likely to cause near-term defects.
- **P3:** real but non-blocking; advisory.

Any open P0-P2 fails the review.

## Calibration (all lenses)

Ground every finding in something you read. Calibrate to the project: read its `AGENTS.md`/`CLAUDE.md` and any review calibration in `.agents/build.md`. No style nits, no machinery a realistic failure does not need, no edge cases needing an implausible sequence. Never approve because tests pass, the prose is polished, or another reviewer approved.

## Risk areas (plan and code lenses)

Check only the areas the target touches:

- **Frontend:** loading, empty, error, disabled and stale states; keyboard and focus; server/client ownership; fetch waterfalls and needless re-renders.
- **Migration and persistence:** forward path, rollback or stated no-rollback, mixed versions during deploy, idempotent backfills, constraints and defaults, one source of truth.
- **Permissions and security:** auth traced from entry point to action, deny by default, server-side checks for model output, tenant and secret boundaries, no sensitive data in errors or logs.
- **Concurrency and lifecycle:** cancellation, duplicate delivery, ordering, atomic related changes, an owner for startup, teardown and reload.
- **Large-file refactors:** before/after line counts, a named responsibility removed from the old file, callers no longer routed through the old path.
