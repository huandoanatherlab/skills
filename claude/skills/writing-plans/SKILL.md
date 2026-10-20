---
name: writing-plans
description: Write an evidence-grounded build plan, or a master plan split into lane plans, and get it reviewed. Use whenever asked to plan, implement, execute or "thực thi / triển khai" a change that spans several files or touches a migration, a contract or permissions; the build itself goes to lane-build or orchestrate.
---

# Writing Plans

T3 Code only: without `mcp__t3-code__*` tools, say this skill runs in T3 and stop.

Decide what to build and how to prove it, get the plan reviewed, then hand it to the build skill. A request to implement or execute starts here unless an approved plan already exists.

Everything for one piece of work lives in `<scratch>/<topic>/`: `plan.md` (or the master plan and its lane plans), then `build/`. The scratch dir comes from `.agents/build.md` (default `.scratch/`) and sits in the **main checkout** (`dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`), never in a worktree, a session scratchpad or host memory, so every thread and worktree sees one copy. It must be git-ignored (`git check-ignore`; otherwise add it to `.git/info/exclude`). A plan the project keeps in the repo (for example `docs/plans/`) is committed there instead; its build state still lives in scratch. Give tools absolute paths.

Talk to the user in their language. Reports and questions are short: decisions first, numbered questions with your recommendation, bullets, no narrative.

## Ground it

Record the branch and base you plan against. Read enough code and primary sources to prove: where the behavior lives now, who should own it afterward, which patterns and contracts to follow, which invariants must hold, which tests guard the area, and which old concepts must be deleted. Never plan a non-trivial change from the request alone. Link paths instead of repeating repo docs. Send lookups and code mapping to cheap helper runs (`agent-run`, Models).

For ports and migrations, classify source material as **copy/adapt**, **reference only**, or **reject**.

For changes to permissions, persistence, migrations, ports or large files, also record: source of truth and contract boundary, runtime versus persisted state, permission path, lifecycle and teardown owner, compatibility policy, non-goals, and what must be deleted rather than wrapped. Large-file refactors need before/after `wc -l` and a named responsibility removed from the old owner.

## Write it

Follow [references/plan-contract.md](references/plan-contract.md). Every slice has a stable ID, dependencies, files, checklist, verification, done criteria, a live proof level and a risk tag. Medium-grained slices, not a procedural script. Aim for 300-400 lines; split into separate files above 500. Give independent subsystems slices with non-overlapping files.

### One plan or a master plan

- **One plan** when the work is one subsystem, or its slices share files or must run in order. It is built in this thread (`lane-build`, solo).
- **Master plan** when the work splits into independent subsystems that can run in parallel for hours: `00-master.md` plus one lane plan per subsystem (`01-<area>.md`, `02-<area>.md`…), each a normal plan with slice IDs prefixed by lane (`FND-S01`, `PRC-S01`). The master plan follows the master sections of the contract: lanes and their dependency graph, merge points, the integration branch, hot files with one owner each, and the resource plan per lane. It is built by `orchestrate`, one T3 lane thread per lane plan.

Never split into lanes to look parallel: two lanes that edit the same files, schema or contract are one lane. At most 3 lanes run at once; order the rest by dependency.

## Review it

Run `review` with the plan lens; you are the fix owner. A master plan is reviewed as one target (master and lane plans together), at the complex tier. Set Review Status in the plan. Never call a plan approved while findings are open; a user stop is `stopped-with-open-findings`.

Then show the user: plan path, review status, open decisions, and one plan or lanes. Continue to the build when the user already asked for it; otherwise ask once.

## Hand off

- One plan: load `lane-build` and run it solo in this thread.
- Master plan: load `orchestrate`; this thread becomes the master.
- Lasting build rules the user gives while planning ("remember to…", gates, roles, fences) go into `.agents/build.md` (`lane-build` references/project.md), never host memory.
