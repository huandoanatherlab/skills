# Delivery lens

An acceptance audit of a finished build against its approved plan, not another code review. Do not edit files or reinterpret an unmet requirement as met. Inputs: plan path and its Review Status, final diff, `build/TRACKER.md` and per-slice evidence, review verdicts, gate commands, deviations.

1. **Slices.** For every slice ID: dependencies done in order; listed files changed or their omission explained; checklist implemented; focused verification evidence exists; review loop complete; live proof matches its level (`none` is met by focused verification; `smoke`, `story`, `suite` need live evidence or a recorded user waiver); done criteria observably true. A slice that changes UI needs browser evidence that each touched page opens, including with empty data; focused tests alone do not prove it. A tracker checkbox alone is not evidence.
2. **Acceptance criteria.** Map each plan-level criterion to direct evidence: behavior, test, diagnostic, file or schema state, or explicit user acceptance.
3. **Architecture and deletion.** Source of truth, ownership, lifecycle, persistence, permissions and public contracts match the plan's target. Removals are proven by grep, file absence, caller search or line count; a wrapper around the old path is not deletion.
4. **Gates.** Run or verify the project's gates proportional to the change; separate failures proven pre-existing on the base commit.
5. **Deviations and tree.** Classify each deviation as accepted (approved), benign (keeps architecture and criteria) or blocking (changes ownership, contracts, persistence, permissions, migrations or user-visible scope without approval). Check the changed files for out-of-scope edits, debug code and missing artifacts.

`DELIVERY INCOMPLETE` if any remains: an incomplete or unreviewed slice; a required live proof not verified and not waived (name the blocker); a criterion without direct evidence; a failed gate not proven pre-existing; a blocking deviation; an old path that should be gone; an open architecture or security decision; a plan review stopped with open findings or never approved (unless the user waived it). A user stop is not completion.

## Report

```markdown
**Plan:** <path>  **Plan review:** approved | waived | stopped-with-open-findings

| Slice | Implementation | Focused verification | Review | Live proof | Status |
| --- | --- | --- | --- | --- | --- |

| Criterion | Evidence | proven / missing |
| --- | --- | --- |

Gates: <command — pass/fail>
Architecture and deletion: <evidence>
Deviations: accepted <…> / benign <…> / blocking <…>
Residual failures: <…>
```

End with exactly one line: `DELIVERY COMPLETE` or `DELIVERY INCOMPLETE`.
