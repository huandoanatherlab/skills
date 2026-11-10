---
name: ath-docs
description: Set up, migrate and maintain a project's docs/ in one standard shape (README, AGENTS, architecture, repo-structure, glossary, decisions/ ADRs, design/NN-*.md) that agents and people can read fast. Modes - init (new project), migrate (restructure an old project's docs), sync (update docs after a build), adr (record a decision). Use for "viết docs", "tài liệu", "ADR", "tái cấu trúc tài liệu", or when ath-execute finishes.
---

# Docs

Every project keeps its lasting documentation in `docs/` at the repo root, in one shape. The docs describe the system **as built** and the decisions behind it. Plans, progress and how-we-got-here never go in them. Templates: [references/templates.md](references/templates.md).

Roles (`ath-builder`, `ath-reviewer`, `ath-scout`): in Claude Code spawn them with the Agent tool (`subagent_type`); elsewhere follow `../ath-execute/roles/README.md`.

```
docs/
  README.md            index: what each doc holds, what to read for which task
  AGENTS.md            rules for keeping docs/ correct (what to update when)
  architecture.md      high-level system: components, connections, infra, main flows
  repo-structure.md    layout, conventions, checks, setup, release and versioning, runbooks
  glossary.md          terms, enums, abbreviations, linked to where code defines them
  decisions/           ADRs: README.md index + NNNN-<title>.md
  design/              NN-<component>.md: detailed technical design per component
  plans/               build plans (ath-plan); archive/ holds finished ones
```

## Writing rules (all modes)

- **Point, don't copy.** Link code paths (`src/billing/rate.ts`) instead of pasting code, schemas or enum values that will drift. The code is the source of truth for exact shapes; docs explain them.
- **One home per fact.** Architecture gives the overview and links to `design/`; design goes deep on one component; terms live only in the glossary.
- **Short and scannable.** Tables and lists over prose. Size caps: README 60 lines, architecture 300, repo-structure 400, each design file 400, each ADR 40. Above a cap, split.
- **Grounded.** Every claim about the system is checked against the code before it is written. Mark anything unverified `(unverified)` instead of guessing.
- Plain words, written in English unless the repo's docs are in another language.

## init (new project or no docs/)

Create the tree from the templates, filled from the code (send area mapping to `ath-scout` agents in parallel). Write ADR 0001 only for decisions that already exist (stack, hosting, data store). Wire the docs into the repo root:
- `AGENTS.md` gets a "Docs" line: start at `docs/README.md`; follow `docs/AGENTS.md` when changing docs.
- `CLAUDE.md` contains `@AGENTS.md` and `@docs/README.md`, so Claude always has the index in context.

## migrate (old project)

1. **Branch:** get a `chore/docs-restructure` branch and worktree, as `ath-plan` step 1 does. The `continuationPrompt` starts with "Continue ath-docs migrate".
2. **Inventory:** every doc-like file (`README*`, `docs/**`, `*.md` outside code, PRD/TDD/spec/ADR/notes folders, wiki exports), with size and last-commit date. Use `ath-scout`.
3. **Map:** a table, one row per old file: target (architecture, repo-structure, glossary, `decisions/`, `design/NN-…`, plans archive, delete), action (move, merge, extract, delete) and a note (stale? contradicted by code?). **Show it to the user and wait for a yes.** This is the only stop.
4. **Write** the new docs from the templates: content extracted from the old files, checked against code, gaps filled from code by scouts. PRD and TDD content is split: still-true behavior and design go to `design/`, decisions go to ADRs, product rationale goes to the ADR's context, and anything obsolete is dropped.
5. **Decisions:** one ADR per real decision found in old docs or in large commits (`git log` for migrations, replacements, adoptions), dated when it was made, status `accepted`, with the note "Recorded retroactively".
6. **Remove** the old files (git keeps history) and fix every link to them (`rg` for the old paths).
7. **Review:** `ath-reviewer`, lens `plan`, target the new `docs/`, with the acceptance "every claim is true against the code; links resolve; nothing in the mapping table was lost". Same triage and a breaker of 3 reviewer turns.
8. **PR**, with the mapping table in the body (in T3 also `link_pull_request` and `watch_pull_request`), then `ath-cleanup` run mode. On merge, `ath-cleanup` merged mode.

## sync (after a build; called by ath-execute)

Input: the diff `<base>..HEAD` and the plan's Decisions. Update only what the change touched, and keep edits small:

| The change… | Update |
| --- | --- |
| adds or removes a component, service, store, queue or external dependency, or changes a main flow | `architecture.md` |
| changes a component's interfaces, data, flows, invariants or failure handling | that `design/NN-…md`; a new component gets the next NN |
| adds a top-level folder, a command or check, a setup step, or changes release or versioning | `repo-structure.md` |
| adds or renames a domain term or enum | `glossary.md` |
| each plan Decision, and any decision made during the build | a new ADR (`adr` below) |

No `docs/` in the shape above: write only the ADRs if `docs/decisions/` exists. Otherwise skip, and suggest `ath-docs migrate` in one line. Commit as `docs: sync <topic>`.

## adr (record a decision)

- File: `docs/decisions/NNNN-<kebab-title>.md`, where NNNN is the highest existing number plus 1, zero-padded to 4 digits. Numbers are never reused or renumbered. Only the thread that finishes a build writes ADRs, so parallel plans cannot collide.
- Use the ADR template; 15–40 lines.
- Add a row to `docs/decisions/README.md`.
- **Superseding:** never rewrite an accepted ADR. Write the new one with `Supersedes: NNNN`, then change the old one's status to `superseded by NNNN` and update both index rows.
- Agents read the index first and open an ADR only when its `area` matches the work.
