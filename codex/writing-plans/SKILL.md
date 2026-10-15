---
name: writing-plans
description: Plan and build a multi-step code change: write an evidence-grounded plan, get it reviewed, then build it slice by slice with Claude builders and reviewers; also pause, resume or report progress on such a build. Use whenever asked to implement, execute or "thực thi / triển khai" a change that spans several files or touches a migration, a contract or permissions, including when the request arrives mid-thread.
---

# Writing Plans

One skill, two phases. **Plan** decides what to build and how to prove it. **Build** executes that plan as coordinator. Run both, start at Build with an approved plan, or pause, resume and report a build from its `TRACKER.md`.

Everything for one piece of work lives in `<scratch>/<topic>/`: `plan.md`, then `build/`. The scratch dir comes from `.agents/build.md` (default `.scratch/`) and sits in the **main checkout** (`dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`), never in a worktree, a session scratchpad or host memory, so every session and worktree sees one copy. It must be git-ignored (`git check-ignore`; otherwise add it to `.git/info/exclude`). Paths below are relative to `<scratch>/<topic>/`; give tools absolute paths.

Talk to the user in their language. Reports and questions are short: decisions first, numbered questions with your recommendation, bullets, no narrative.

# Phase 1: Plan

## Ground it

Record the branch and base you plan against. Read enough code and primary sources to prove: where the behavior lives now, who should own it afterward, which patterns and contracts to follow, which invariants must hold, which tests guard the area, and which old concepts must be deleted. Never plan a non-trivial change from the request alone. Link paths instead of repeating repo docs.

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

Requires a plan with Review Status `approved` and no open architecture decision. Read `.agents/build.md` ([references/project.md](references/project.md)); if it is missing, derive it from `AGENTS.md`/`CLAUDE.md` and the repo, and write it once the user approves. Lasting build rules the user gives ("remember to…", gates, roles, fences) go into that file, never host memory.

1. Show one table: plan, base branch and HEAD, worktree, dirty files, environment, roles with model, effort and launcher (flag any role in `.agents/build.md` that differs from the `agent-run` defaults and ask whether to keep it), slice order and parallel groups. Wait for "go" unless already given.
2. `git fetch`, then re-check the plan's file and line references against `origin/<base>`.
3. In `build/`, write `TRACKER.md`, `QUESTIONS.md`, `briefs/COMMON.md` and `briefs/REVIEW.md` from [references/templates.md](references/templates.md), filled with the project's gates and fences.
4. Create one worktree per slice that runs in parallel (`git worktree add -b <branch> <path> origin/<base>`, next to the repo unless `.agents/build.md` says otherwise); sequential slices share one. Log every worktree, branch, database and long-running process you create under Resources in `TRACKER.md`.
5. Start the environment the live checks need, if any.

Choose a mode per slice:

- **cross** (default): Sonnet 5.5 builder at medium (Opus 5.5 for a heavy slice) and a reviewer by tier (Haiku 5.5, or Opus 5.5 at medium or high, per `agent-run` Models), each a separate run.
- **inline**: tiny or tightly coupled slices sharing files. You build and commit; the reviewer is still a separate run, never you.

The roles in `.agents/build.md` override these defaults; the user's current message overrides both.

**Small build:** a plan of one or two `normal`-risk slices built inline skips the Finish whole-diff review and delivery audit; `TRACKER.md` keeps only its header and slice table, and the report goes in your final message. Never skipped: a plan with Review Status `approved` before the first code edit (a pending verify round is not approval), `triage-N.md`, and a separate reviewer run.

## Each slice

1. **Build.** Write `build/runs/<slice>/prompt.md` ("Read briefs/COMMON.md first", slice ID, named tests, extra fences), then launch the builder with it (script form: `agent-run start build/runs/<slice> claude builder --cwd <worktree>`, in the background). Before any launch, check `TRACKER.md` and `task_status`/`agent-run status` so the slice has no live run already. Log launcher and id in `TRACKER.md`, and write the next slice's prompt while it runs.
2. **Check the claim.** Read the whole diff and re-run the slice's named tests and focused gates. A builder's report is a claim, not evidence. If the builder exited without committing (usually a forbidden background job), resume it with the rule restated. A failure is pre-existing only if the same test fails on the base commit.
3. **Review** with the `review` loop, code lens: confirm `git diff --stat <base>..HEAD` in the worktree is not empty, render `briefs/REVIEW.md` into `build/runs/<slice>-review/prompt.md`, launch the reviewer with it (script form: `agent-run start build/runs/<slice>-review claude reviewer --cwd <worktree>, plus the tier's `--model`/`--effort``), and follow `review` for triage and same-reviewer validation. You are the fix owner: send accepted fixes back to the same builder (the launcher's follow-up in `agent-run`).
4. **Live proof** at the slice's level ([references/project.md](references/project.md)), between builds, never while a builder edits a watched dev server.
5. **Record** commits, round count, verdict and evidence in `TRACKER.md`. When the user is present, post one line (slice, verdict, what is next). Then launch the next slice at once; answering a question mid-run never ends the turn. A question of yours never blocks work that does not depend on it: ask in plain text or log it in `QUESTIONS.md` with your recommended default, keep processing finished runs and launching independent slices, and use a blocking question tool only when nothing else can move.

A slice is done when its review loop is complete, its live proof passed, and its commits are in `TRACKER.md`.

**Too big:** a builder run well past the plan's 90-minute target (about 2 hours), or a review with more than 5 P0-P2 findings, means the slice is too big. Stop it at a commit and split the rest into sub-slices with their own IDs in `TRACKER.md`, in parallel where files allow. Check a builder once at about 90 minutes (`task_status` or `agent-run status`) so this rule is applied while it still saves time.

Run slices in parallel only when files, state and contracts do not overlap: one worktree each (and one database each when tests write data), at most 3 builders and 6 agent runs at once. At each milestone merge the slice branches in dependency order into the build branch, run the full gates on the merged HEAD before anything moves to the base branch, then remove the merged worktrees and branches and record it.

**When reality disagrees with the plan:** a small detail that keeps architecture and acceptance criteria goes in `TRACKER.md`. A change to ownership, contracts, persistence, permissions, migrations or user-visible scope stops the build: update the plan, re-run its review, then continue.

## Keep it cheap

- **Small edits are yours.** Copy, spacing, P3 findings and fixes under about 20 lines: edit and commit them yourself. A builder run costs a fresh context, a review and a wait. They are reviewed with the slice's next round or the whole-diff review.
- **Helpers by job.** Lookups, code mapping and long live-test plans go to the cheapest model that does the job (`agent-run`, Models), not to a builder or to you.
- **Tiered gates.** Fix rounds run focused checks on the changed area; the full gates run at each milestone merge and at Finish, before Ship.
- **One piece of work per thread.** Every turn re-reads the whole thread. When the next feature starts, or your context passes about 200K tokens, pause as below and hand off.

## Finish

1. **Whole-diff review** with `review`, code lens, by a fresh reviewer: dead code, duplicated helpers, oversized files, slice IDs in comments.
2. **Gates** from `.agents/build.md`; classify each failure against the base commit.
3. **Live check** of every `smoke`/`story`/`suite` slice end to end, evidence in `build/evidence/`.
4. **Acceptance audit** with `review`, delivery lens, by a fresh Opus 5.5 reviewer at high; fix what it finds and repeat that slice's review.
5. **Report** in `build/FINAL-REPORT.md`: commit range and deploy order, migration commands per environment, slices with models, verdicts, rejected findings with reasons, deviations, live results with evidence paths, failed or skipped gates, a short manual QA guide, open questions, delivery verdict. Never hide a failure behind "tests pass".
6. **Ship** per `.agents/build.md` Git: commit any leftovers in logical groups, push and open a PR to the base branch with the report summary and evidence images, or merge if that is the project's flow. Without a Git section or prior authority, ask once.
7. **Clean up** everything under Resources in `TRACKER.md`: stop dev servers, browsers, background waits and processes you started; cancel live T3 tasks; drop temporary databases and containers; remove merged worktrees and branches, build output and unused volumes; in `<scratch>/<topic>` keep `plan.md` and `build/FINAL-REPORT.md`. Before removing a worktree, end every process and agent session whose working directory is inside it; on `Directory not empty` or `Permission denied`, find and stop the holder instead of retrying the delete. Never touch other agents' worktrees. List anything kept in the report.

## Pause, resume, status

- **Pause** ("tạm dừng", handoff, context near full): stop builders at a commit, let read-only reviewers finish and list their ids under live runs so resume picks up the result instead of relaunching, then update the top of `TRACKER.md` (Now, Progress, live runs, next action) so a fresh session needs nothing else.
- **Resume** ("tiếp tục", a new session or machine): find the newest `<scratch>/*/build/TRACKER.md` in the main checkout. Reconcile it with `git worktree list`, branches, `task_status`/`agent-run status`, and commits on each slice branch; fix the tracker where it is stale. Report progress in one line, then continue from Now without relaunching anything that is still running.
- **Status** ("tiến độ", "bao nhiêu %"): slices complete over total and percent, slices built but not reviewed, what is running and for how long, other plans under `<scratch>/`.

## Unattended

When the user is away and said to continue: fix bugs, log clear-value design changes, cut machinery, and put everything else in `QUESTIONS.md` with your recommendation. A provider error (429, 503, capacity, usage limit) gets one retry on the same model; then that slice waits in `QUESTIONS.md` and you keep going with the others (`agent-run`, Pairing: no fallback model). Check-ins are one line: what runs, which model, how long, where the evidence is. Report only failures and the end, not "still running". Before your context runs out, pause and hand off to a fresh session.
