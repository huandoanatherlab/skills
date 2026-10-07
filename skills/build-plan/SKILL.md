---
name: build-plan
description: Build an approved multi-slice plan as coordinator, with builders from one model family, reviewers from another, triage, per-slice commits and a live check; use to execute, implement or resume a written plan, not to write one.
---

# Build Plan

You are the **coordinator**. Builders write and commit code, reviewers check it, you triage, integrate, verify live and report. Run state lives on disk so any session, on Claude or Codex, can resume it.

Read the host notes first: [references/host-claude.md](references/host-claude.md) or [references/host-codex.md](references/host-codex.md).

Run builders and reviewers with `agent-run` (skill `agent-run`; on `PATH` after install, else `../agent-run/scripts/agent-run` from this skill).

## Preconditions

- A plan with stable slice IDs, dependencies, file ownership, verification and done criteria per slice, and a live proof level per slice. If any is missing, go back to `writing-plans`.
- No open architecture decision that would change the implementation.
- The project config: `.agents/build.md` ([references/project-config.md](references/project-config.md)). If it is missing, read `AGENTS.md`/`CLAUDE.md` and the repo, propose one, and write it once the user approves.

## Modes

Pick per slice; the plan may suggest one.

| Mode | When | Builder | Reviewer |
| --- | --- | --- | --- |
| `cross` (default) | Normal slices | `agent-run`, host family | `agent-run`, other family |
| `inline` | Tiny or tightly coupled slices sharing files | You | `agent-run`, other family |
| `native` | Other family unavailable | Native subagent | Fresh native subagent |

You never review your own code. The roles table in the project config overrides these defaults; the user overrides both.

## 1. Kick off

Show the user one table: plan path, branch and HEAD, worktree, dirty files, environment (lane, URL) if any, roles with models, slice order and which slices can run in parallel. Wait for "go" unless the user already gave it.

Then:

1. Re-check the plan's file and line references against HEAD. Stop and update the plan if reality materially differs.
2. Create the build dir `<scratch>/<topic>/build/` (scratch dir from the project config, default `.scratch/`). Make sure git ignores it (`git check-ignore`; otherwise add it to `.git/info/exclude`).
3. In the build dir, write `TRACKER.md` from [references/tracker.md](references/tracker.md), `QUESTIONS.md`, `briefs/COMMON.md` from [references/builder-brief.md](references/builder-brief.md) and `briefs/REVIEW.md` from [references/review-brief.md](references/review-brief.md), filled with the project's gates, fences and scratch paths.
4. Write `<build dir>/runs/<slice>/prompt.md` for the first slice: "Read briefs/COMMON.md first", the slice ID and plan section, named tests, extra fences.
5. Start the environment the live check needs, if any (project config `Live check → start`).

## 2. Each slice

1. **Build.** `agent-run start <build dir>/runs/<slice> <family> builder --cwd <worktree>` in the background. While it runs, write the next slice's prompt.
2. **Check the claim.** Read the whole diff yourself and re-run the slice's named tests and gates. A builder's report is a claim, not evidence. To call a failure pre-existing, run the same test on the base commit.
3. **Review.** Render `briefs/REVIEW.md` for the slice into `<build dir>/runs/<slice>-review/prompt.md` and run `agent-run start <build dir>/runs/<slice>-review <other family> reviewer --cwd <worktree>`. The loop below follows `thermal-review-loop`.
4. **Triage** into `<build dir>/runs/<slice>/triage-N.md` before touching code: one line per finding, accept or reject, and why. Rules below.
5. **Fix.** Send accepted findings to the same builder: `agent-run resume <build dir>/runs/<slice> <fix-prompt>`. Then send the reviewer every finding with its fix or rejection reason: `agent-run resume <build dir>/runs/<slice>-review <verify-prompt>`.
6. **Record** the builder's commits (the slice commit plus one per fix round); in `inline` mode commit yourself, staging by explicit path. Do a quick live check for user-visible slices. Log commit, verdict and evidence in `TRACKER.md`.
7. **Launch the next slice immediately.** Answering a user question mid-run never ends the turn without starting the next step.

A slice is done when its reviewer approves its own findings with no P0/P1 open, its live proof (if `smoke` or `story`) passed, and its commits are in `TRACKER.md`. Slices tagged risky in the plan (migration, persistence, permissions, security, public contract) also need a fresh reviewer's first-pass `APPROVED`.

**Parallel slices** only when files, state and contracts do not overlap. Give each its own worktree (and its own database when tests write data), run at most 3 builders and 6 agent processes at once, and merge the worktrees yourself.

## Triage

Reviewers over-engineer, Codex especially. Accept:

- bugs a user can hit, lost or corrupted data;
- broken contracts, type errors, wrong file or line claims;
- plan checklist items not met;
- a violation of the project's own rules (`AGENTS.md`/`CLAUDE.md`).

Reject, with a one-line reason:

- added machinery the realistic case does not need: retry ladders, flags, extra state, audit rows, locks;
- edge cases needing an implausible sequence of events;
- wider test matrices, copy or DOM-shape assertions;
- anything the plan cut on purpose.

Never accept a whole round without the list. If a reviewer insists on a rejected finding twice, stop arguing: ask the user, or log it in `QUESTIONS.md` when unattended, and move on.

## Plan deviations

Small detail that keeps architecture and acceptance criteria: log it in `TRACKER.md` and continue. A change to ownership, public contracts, persistence, permissions, migration policy or user-visible scope: stop, update the plan, get it reviewed, then continue.

## 3. Finish

1. **Whole-diff review** by a fresh reviewer from the other family, using `code-quality-review`: clean structure, no dead code or duplicated helpers, no slice IDs in code comments. Triage and fix as above.
2. **Gates** from the project config. Classify every failure against the base commit.
3. **Live check** per [references/live-check.md](references/live-check.md): one row per user-visible behavior, evidence saved under `<build dir>/evidence/`. Label results from seeded or synthetic data.
4. **Delivery audit** with `verify-plan-delivery`. Fix what it finds and repeat the affected slice review.
5. **Report** in `<build dir>/FINAL-REPORT.md`: commit range and deploy order, slices with models, review verdicts, rejected findings with reasons, deviations, live-check results with evidence paths, failed or skipped gates, open questions, and the delivery verdict. Do not hide a failure behind "tests pass".

## Running unattended

When the user is away and said to continue: fix bugs; make a design change only when it clearly adds value, and log it; cut machinery; put everything else in `QUESTIONS.md` with your recommendation and keep going.

Each check-in is one line: what is running, which model, for how long, where the evidence is (`agent-run status <build dir>/runs`). Report only failures and the end, not "still running".

If your context grows too large, write the current step, running processes and granted authority at the top of `TRACKER.md`, then hand off to a fresh session pointed at it.

## Gotchas

- Builders quit early when they start background jobs; the brief forbids them. If a builder exits without committing, resume it with that rule restated.
- Do not live-test while a builder is editing a watched dev server; restarts kill live sessions. Live-test between builds.
- Builders must not migrate or run whole suites against a database a live environment uses, touch another worktree, or post to real external services.
- Confirm a background agent actually started (`agent-run status` shows `running`) before reporting it as running.
