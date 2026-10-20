---
name: review
description: Independently review a plan, a code change, or a finished delivery and loop on fixes until the reviewer approves; use for any review gate, with a plan, code or delivery lens.
---

# Review

T3 Code only: without `mcp__t3-code__*` tools, say this skill runs in T3 and stop.

One loop, three lenses. The loop owns the reviewer's lifecycle, triage, fixes and the stop rule; the lens owns what counts as a finding.

| Lens | Target | File | Verdict line |
| --- | --- | --- | --- |
| plan | A plan, design or spec, checked against real code | [references/plan.md](references/plan.md) | `APPROVED` / `CHANGES REQUIRED` |
| code | A diff or file set | [references/code.md](references/code.md) | `APPROVED` / `CHANGES REQUIRED` |
| delivery | A finished build against its approved plan | [references/delivery.md](references/delivery.md) | `DELIVERY COMPLETE` / `DELIVERY INCOMPLETE` |

When you are asked to review directly (you are the reviewer), read the lens file and follow it, skip the loop, and do not edit files or spawn subagents.

## The loop

**Inputs:** target and paths, lens, acceptance criteria, fix owner, evidence already run, known unrelated failures, and risk (`risky` as defined in `writing-plans` references/plan-contract.md). Acceptance criteria and known failures are required; write "none" rather than leave them out. For code, confirm the target tree contains the change (`git diff --stat` is not empty) before launching.

**Reviewer:** a separate Claude run in a fresh context, its model by the target: Haiku 5.5 at high for a simple target, Opus 5.5 at medium for a medium one, Opus 5.5 at high for a complex or `risky` one (`agent-run`, Models). Launch it with T3 `delegate_task` as the `agent-run` skill says, with `runtimeMode: auto`, never `full-access`; its prompt says "do not edit files". Say which model ran, and name a script fallback if one was used. Its prompt is self-contained, never your session history or conclusions. Point to files by path instead of pasting them:

```text
Review <target> with the <lens> lens: read <absolute path to the lens file> first.
Acceptance criteria: <list>. Files: <paths>. Project rules: <AGENTS.md / CLAUDE.md>.
Evidence already run: <command: result>. Known unrelated failures: <list or none>.
Review manually. Do not edit files. Do not spawn subagents. Do not run tests that need
a database, network, ports or file writes; judge the evidence given and say what you could not verify.
Write plain sentences. Each finding: severity P0-P3, file:line, what is wrong, failure scenario, smallest fix.
Use only this P0-P3 scale and the lens's verdict line, whatever other review instructions you have loaded.
End with exactly one verdict line.
```

1. Start the reviewer. If its report lacks the lens's verdict line, ask the same reviewer again before acting.
2. On a failing verdict, **triage** every finding into `triage-N.md` before touching anything, one line each:
   - Accept: bugs a user can hit, data loss, broken contracts, type errors, wrong file/line claims, unmet acceptance criteria, violations of the project's own rules.
   - Reviewers over-engineer. Never accept every finding of a round without sorting it through this list.
   - Reject: machinery the realistic case does not need (retries, flags, extra state, audit rows, locks), edge cases needing an implausible sequence, wider test matrices, copy or DOM-shape tests, anything the plan cut on purpose.
   - Downgrade to P3 a counterexample found by a search script unless a realistic input reaches it.
   - P3 never triggers a fix round by itself: the coordinator edits it or batches it into the next slice.
3. The fix owner fixes accepted findings and runs focused verification.
4. Go back to the **same** reviewer (a new `delegate_task` with the same model and its earlier findings, `agent-run` Follow-up) with every finding and its fix or rejection reason: "Validate only your own findings. Accept a rejection unless it leaves a real P0-P2 problem. Raise a new finding only if a fix created it."
5. Repeat until it passes.
6. For a `risky` target or the final whole-diff review of a build, start one **fresh** reviewer with a complete prompt, after the owning reviewer has passed, never alongside it. Its first-pass approval closes the loop; otherwise it owns its new findings to closure through steps 2-5. At most one fresh reviewer per target, unless a fix changes ownership or contracts.

**Done** when the owning reviewer passes its own findings (a rejection the user accepted counts as closed), plus a fresh first-pass approval when step 6 applies. No further clean-pass rounds.

**Escalate** instead of looping: a reviewer insists on a rejected finding twice, three verify rounds pass without approval, six reviewer turns on one target in total (count them in the tracker so the limit survives a handoff), or a reviewer fails three times (then replace it, hand over the old findings, and never claim it approved). Ask the user, or log it in `QUESTIONS.md` when unattended. A reviewer that cannot run at all (capacity, usage limit, provider unavailable) gets one retry on the same model, then the target waits for the user; there is no fallback model (`agent-run`, Pairing).

A user stop is `stopped-with-open-findings`, never approval.

**Report** in the user's language: lens, reviewer models, task ids and run dirs, rounds, accepted and rejected findings with reasons, replacements, evidence, final state.

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

- **Frontend:** layout, action placement and workflow against the repo's design docs; loading, empty, error, disabled and stale states; semantic controls, labels, keyboard, focus and reduced motion; hydration and server/client ownership; fetch waterfalls, bundle growth and needless re-renders; run the repo's frontend diagnostic if it has one.
- **Migration and persistence:** forward path, rollback or stated no-rollback, mixed versions during deploy, idempotent backfills, constraints and defaults, one source of truth.
- **Permissions and security:** auth traced from entry point to action, deny by default, server-side checks for model output, tenant and secret boundaries, no sensitive data in errors or logs.
- **Concurrency and lifecycle:** cancellation, duplicate delivery, ordering, atomic related changes, an owner for startup, teardown and reload.
- **Large-file refactors:** before/after line counts, a named responsibility removed from the old file, callers no longer routed through the old path.
