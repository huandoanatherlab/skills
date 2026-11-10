---
name: ath-plan
description: Turn a non-trivial change into an approved, evidence-grounded plan on its own branch and worktree, with slices that have machine-checkable acceptance, ready for ath-execute. Use when asked to plan, implement, build, "làm", "viết plan", "thực thi" or "triển khai" something that spans several files or packages, or touches a migration, contract, auth or permissions. Skip it for a small change.
---

# Plan

Talk to the user in their language, short: decisions first, numbered questions each with your recommendation. Files and agent prompts are in English.

## 0. Is a plan needed?

**Small** (just do it, no plan, no sub-agents): about 3 files or fewer, one package, no migration, contract, auth or permission change, one reviewable step. Make the change on the current branch (or a branch if asked), run the repo's checks, report what changed and what you ran. If it grows past this line while you work, stop and plan.

**Discussion only** ("thảo luận", "chưa làm gì", exploring options): answer and explore; create no branch and write no plan until the user asks.

Otherwise continue.

## 1. Main branch and worktree

All work for one topic lives on one **main branch**, cut from the repo's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, usually `develop` or `main`) unless the user names another base. Name it `feat/<topic>`, `fix/<topic>` or `chore/<topic>` with a short kebab-case topic. Plans, code and docs are committed there, and it ends as one PR into the base.

- **Already in a worktree** (`git rev-parse --git-dir` differs from `--git-common-dir`): use its branch as the main branch.
- **In T3** (`mcp__t3-code__*` tools available): move this thread with `t3_worktree_handoff`: `branch: <main branch>`, `baseRef: origin/<base>`, `startFromOrigin: true`, and a `continuationPrompt` that starts with "Continue ath-plan" and carries everything the next turn needs: topic, base, the user's request verbatim, every decision made so far, and the next step. Tell the user in one line first. Make it the **last call of the turn**: the turn then ends with a "provider event stream closed" error, which is expected, and the continuation runs in the new worktree. Write nothing before the move; uncommitted files do not follow.
- **Elsewhere:** if the checkout is clean, `git fetch` and `git switch -c <main branch> origin/<base>` here. If it is dirty, or the user wants the checkout left alone, `git worktree add ../<repo>-<topic> -b <main branch> origin/<base>`, and ask the user to open a session there (Claude Code can also switch with `EnterWorktree`).

Push the main branch once it has its first commit.

## 2. Ground it

Never plan a non-trivial change from the request alone. Read `docs/README.md` and the docs it points to for the touched area (architecture, design, glossary, and the decisions index), then prove from code: where the behavior lives now, who should own it afterward, which patterns and contracts to follow, which invariants must hold, which tests guard the area, and what must be deleted rather than wrapped.

Send lookups and code mapping to `ath-scout` (several at once run in parallel); keep only their conclusions. Roles (`ath-builder`, `ath-reviewer`, `ath-scout`): in Claude Code spawn them with the Agent tool (`subagent_type`); elsewhere follow `../ath-execute/roles/README.md`. Record the base commit.

## 3. Write it

Follow [references/plan-format.md](references/plan-format.md). Plans live in `docs/plans/<topic>/` on the main branch.

- **One plan** (`plan.md`) when the work fits in about 8 slices. Slices in the same `group` can run in parallel when they touch no common files.
- **Several plans** (`00-index.md` plus `01-<area>.md`, `02-<area>.md`…) when it is bigger, or splits into independent areas. Each plan file is built on its own worktree and branch, then merged into the main branch. Plans that touch the same files, schema or contract are one plan, or run one after another.
- Every slice has acceptance checks that a machine (or a named live observation with evidence) can decide. This is the definition of done; write it before anything else in the slice.
- Write a `<plan>.progress.json` next to each plan file from the format, every check `"pass": false` (and `00-index.progress.json` for an index).
- Decisions the plan makes go in its **Decisions** section; they become ADRs in `docs/decisions/` when the build finishes (`ath-docs` sync).

## 4. Review it

Spawn `ath-reviewer` (`name: plan-review`) with: "Lens: plan. Target: <abs paths of the plan files>. Base: <commit>. Project rules: <AGENTS.md/CLAUDE.md>." Do not paste your reasoning into it.

On `CHANGES REQUIRED`, triage each finding: accept real problems; reject over-engineering, implausible edge cases and anything the plan cut on purpose, with a one-line reason. Fix the plan, then continue the same `plan-review` with each finding marked fixed or rejected; it keeps its context.

**Breaker:** at most 3 reviewer turns. Still open after that: stop and show the user the disputed findings with your recommendation.

## 5. Commit and hand over

Commit the plan files and progress files (`docs(plan): <topic>`) and push. Show the user: plan paths, a table of slices (or plans) with groups and dependencies, the review result, and numbered open decisions with your recommendation. Then wait for the go ("chốt", "làm đi"), unless the user already said to build ("làm luôn", "viết plan và làm đi"). On go, record it in the progress file (`approved`), load `ath-execute`, and start in this same thread.

Lasting rules the user gives while planning ("always…", "never…") go into the repo's `AGENTS.md`, not into agent memory.
