---
name: writing-plans
description: Plan and build a multi-step code change: write an evidence-grounded plan, get it reviewed, then build it slice by slice with Claude builders and Codex reviewers.
---

# Writing Plans

One skill, two phases. **Plan** decides what to build and how to prove it. **Build** executes that plan as coordinator. Run both, start at Build with an approved plan, or resume a build from its `TRACKER.md`.

Everything for one piece of work lives in `<scratch>/<topic>/`: `plan.md`, then `build/`. The scratch dir comes from `.agents/build.md` (default `.scratch/`) and must be git-ignored (`git check-ignore`; otherwise add it to `.git/info/exclude`). Paths below are relative to `<scratch>/<topic>/`; give tools absolute paths.

# Phase 1: Plan

## Ground it

Read enough code and primary sources to prove: where the behavior lives now, who should own it afterward, which patterns and contracts to follow, which invariants must hold, which tests guard the area, and which old concepts must be deleted. Never plan a non-trivial change from the request alone. Link paths instead of repeating repo docs.

For ports and migrations, classify source material as **copy/adapt**, **reference only**, or **reject**.

For changes to permissions, persistence, migrations, ports or large files, also record: source of truth and contract boundary, runtime versus persisted state, permission path, lifecycle and teardown owner, compatibility policy, non-goals, and what must be deleted rather than wrapped. Large-file refactors need before/after `wc -l` and a named responsibility removed from the old owner.

## Write it

Follow [references/plan-contract.md](references/plan-contract.md). Every slice has a stable ID, dependencies, files, checklist, verification, done criteria, a live proof level and a risk tag. Medium-grained slices, not a procedural script. Aim for 300-400 lines; split into separate files above 500. Give independent subsystems slices with non-overlapping files.

## Review it

Run `review` with the plan lens; you are the fix owner. Set Review Status in the plan. Never call a plan approved while findings are open; a user stop is `stopped-with-open-findings`.

Then show the user: plan path, review status, open decisions. Continue to Build when the user already asked for it; otherwise ask once.

# Phase 2: Build

You are the **coordinator**. Builders write and commit code, reviewers check it, you triage, verify and report. You never review your own code. Run state lives in `build/` so any session on Claude or Codex can resume it.

Read [references/hosts.md](references/hosts.md) for your host. Launch every builder and reviewer the way the `agent-run` skill says: T3 `delegate_task` when the tool is there, else the host's subagent tool, else the `agent-run` script. Models by job are in that skill too.

## Start

Requires a plan with Review Status `approved` and no open architecture decision. Read `.agents/build.md` ([references/project.md](references/project.md)); if it is missing, derive it from `AGENTS.md`/`CLAUDE.md` and the repo, and write it once the user approves.

1. Show one table: plan, branch and HEAD, worktree, dirty files, environment, roles with model, effort and launcher, slice order and parallel groups. Wait for "go" unless already given.
2. Re-check the plan's file and line references against HEAD.
3. In `build/`, write `TRACKER.md`, `QUESTIONS.md`, `briefs/COMMON.md` and `briefs/REVIEW.md` from [references/templates.md](references/templates.md), filled with the project's gates and fences.
4. Create one worktree per slice that runs in parallel (`git worktree add`, next to the repo unless `.agents/build.md` says otherwise); sequential slices share one.
5. Start the environment the live checks need, if any.

Choose a mode per slice:

- **cross** (default): Opus 5.5 builder at medium and Codex `gpt-6.1-sol` reviewer at high, each a separate run.
- **inline**: tiny or tightly coupled slices sharing files. You build and commit; the reviewer is still a separate run, from the other family than you.

The roles in `.agents/build.md` override these defaults; the user overrides both.

## Each slice

1. **Build.** Write `build/runs/<slice>/prompt.md` ("Read briefs/COMMON.md first", slice ID, named tests, extra fences), then launch the builder with it (script form: `agent-run start build/runs/<slice> claude builder --cwd <worktree>`, in the background). Confirm it started, log launcher and id in `TRACKER.md`, and write the next slice's prompt while it runs.
2. **Check the claim.** Read the whole diff and re-run the slice's named tests and gates. A builder's report is a claim, not evidence. If the builder exited without committing (usually a forbidden background job), resume it with the rule restated. A failure is pre-existing only if the same test fails on the base commit.
3. **Review** with the `review` loop, code lens: render `briefs/REVIEW.md` into `build/runs/<slice>-review/prompt.md`, launch the reviewer with it (script form: `agent-run start build/runs/<slice>-review codex reviewer --cwd <worktree>`), and follow `review` for triage and same-reviewer validation. You are the fix owner: send accepted fixes back to the same builder (the launcher's follow-up in `agent-run`).
4. **Live proof** at the slice's level ([references/project.md](references/project.md)), between builds, never while a builder edits a watched dev server.
5. **Record** commits, verdict and evidence in `TRACKER.md`. Then launch the next slice at once; answering a question mid-run never ends the turn.

A slice is done when its review loop is complete, its live proof passed, and its commits are in `TRACKER.md`.

Run slices in parallel only when files, state and contracts do not overlap: one worktree each (and one database each when tests write data), at most 3 builders and 6 agent runs at once, and you merge the worktrees.

**When reality disagrees with the plan:** a small detail that keeps architecture and acceptance criteria goes in `TRACKER.md`. A change to ownership, contracts, persistence, permissions, migrations or user-visible scope stops the build: update the plan, re-run its review, then continue.

## Keep it cheap

- **Small edits are yours.** Copy, spacing and fixes under about 20 lines: edit and commit them yourself. A builder run costs a fresh context, a review and a wait. They are reviewed with the slice's next round or the whole-diff review.
- **Helpers by job.** Lookups, code mapping and long live-test plans go to the cheapest model that does the job (`agent-run`, Models), not to a builder or to you.
- **One piece of work per thread.** Every turn re-reads the whole thread. When the next feature starts, or your context passes about 200K tokens, hand off as described under Unattended.

## Finish

1. **Whole-diff review** with `review`, code lens, by a fresh reviewer: dead code, duplicated helpers, oversized files, slice IDs in comments.
2. **Gates** from `.agents/build.md`; classify each failure against the base commit.
3. **Live check** of every `smoke`/`story`/`suite` slice end to end, evidence in `build/evidence/`.
4. **Acceptance audit** with `review`, delivery lens, by a fresh `gpt-6.1-sol` reviewer; fix what it finds and repeat that slice's review.
5. **Report** in `build/FINAL-REPORT.md`: commit range and deploy order, slices with models, verdicts, rejected findings with reasons, deviations, live results with evidence paths, failed or skipped gates, open questions, delivery verdict. Never hide a failure behind "tests pass".

## Unattended

When the user is away and said to continue: fix bugs, log clear-value design changes, cut machinery, and put everything else in `QUESTIONS.md` with your recommendation. Check-ins are one line: what runs, which model, how long, where the evidence is (`task_status` in T3, `agent-run status build/runs` for script runs). Report only failures and the end, not "still running". Before your context runs out, update the top of `TRACKER.md` (current step, running processes, granted authority) and hand off to a fresh session.
