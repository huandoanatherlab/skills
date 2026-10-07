---
name: thermal-review-loop
description: Run a review-and-fix loop on a plan, code change or design until its own reviewer approves, with triage of every finding; use when work must be independently reviewed before it is called done.
---

# Thermal Review Loop

Keep review orchestration separate from review judgment. This skill owns the reviewer's lifecycle, triage, fixes and the stop rule. The lens owns what counts as a finding: `plan-review` for plans, `code-quality-review` for code, unless the user names another.

## Inputs

Define before dispatching review:

- target and paths (plan, diff range, files)
- lens
- acceptance criteria
- fix owner
- verification evidence already run
- known unrelated dirt or failures
- risk: `normal`, or `risky` when the target touches migrations, persistence, permissions, security or a public contract

## Reviewer

- **Different family by default.** When the author is Claude, the reviewer is Codex, and the reverse. Run it with `agent-run start <run-dir> <family> reviewer`. Use a native subagent only when the other family is unavailable, and say so.
- **Fresh context.** A self-contained packet from [references/reviewer-packet.md](references/reviewer-packet.md). Never fork session history or pass your own conclusions.
- **Same reviewer for validation.** `agent-run resume <run-dir> …`, or SendMessage to the same named subagent.
- Every reviewer uses the lens, reviews manually, does not edit files or spawn agents, gives file:line and a concrete fix per finding, and ends with exactly `APPROVED` or `CHANGES REQUIRED`. If the verdict or lens is missing, resume that reviewer and ask again before acting.

## Loop

1. Start one reviewer with the packet.
2. On `CHANGES REQUIRED`, **triage** every finding into `triage-N.md` before touching anything: accept or reject, one line why.
   - Accept: bugs a user can hit, data loss, broken contracts, type errors, wrong file/line claims, unmet acceptance criteria, violations of the project's own rules.
   - Reject: machinery the realistic case does not need (retries, flags, extra state, audit rows, locks), edge cases needing an implausible sequence, wider test matrices, copy or DOM-shape tests, anything the plan cut on purpose.
3. The fix owner fixes accepted findings and runs focused verification.
4. Return every finding to the **same** reviewer with its fix or rejection reason and the new evidence.
5. Repeat until that reviewer returns `APPROVED`.
6. If the target is `risky`, or this is the final whole-diff review of a build, start one **fresh** reviewer with a complete packet. A first-pass `APPROVED` closes the loop; otherwise it owns its new findings and the loop repeats from step 2 with it.

Never accept a whole round without the triage list.

## Stop rule

Complete when the owning reviewer approved its own findings and no P0/P1 finding is open, plus a fresh first-pass `APPROVED` when step 6 applies. Do not add clean-pass rounds beyond that.

## Escalation

- A reviewer insists on a rejected finding twice: stop arguing, ask the user (or log it in `QUESTIONS.md` when unattended) and continue.
- Three verify rounds without approval: report the open set to the user with your recommendation.
- A reviewer process fails or returns no verdict three times: start a fresh replacement with the old findings, fixes and evidence, and record the replacement. Never claim the replaced reviewer approved.

## User stop

Stop when the user asks. Mark `stopped-with-open-findings` if any finding or required fresh pass remains, and report the open state plainly. A user stop is not approval.

## Summary

Report: lens, reviewer models and run dirs, rounds, accepted and rejected findings with reasons, replacements, verification evidence, unrelated dirt, and the final state: `complete` or `stopped-with-open-findings`.
