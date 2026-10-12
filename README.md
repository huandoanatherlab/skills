# Skills

Plan, build, review and debug skills, with one set for Claude Code and one for Codex. Both sets mix the two families the same way: Claude models build, a Codex model reviews.

```bash
./install.sh --dry-run
./install.sh
```

`install.sh` links each `claude/<name>` into `~/.claude/skills` and each `codex/<name>` into `~/.codex/skills`. It links `bin/agent-run` into `~/.local/bin`, and moves anything it replaces to `~/.skills-backup/<time>/`.

## Flow

```
writing-specs (optional) → writing-plans: plan ─review(plan)→ build ─review(code)→ review(delivery)
                                                                 └─ agent-run: launches builder and reviewer runs
```

| Skill | Job |
| --- | --- |
| `writing-plans` | Plan (slices, live proof, risk), get it reviewed, build it as coordinator with builder and reviewer runs, then ship and clean up; pause, resume and status from `TRACKER.md` |
| `review` | Review loop with triage and same-reviewer approval; lenses: plan, code, delivery |
| `agent-run` | Models by job and the launch order for builder, reviewer and helper runs |
| `writing-specs` | Lasting product (PRD) and design (TDD) docs in `docs/` |
| `systematic-debugging` | Evidence-driven debugging in Quick, Standard or Deep mode; hands large fixes to `writing-plans` and finished fixes to `review` |

## Models

| Work | Model | Effort |
| --- | --- | --- |
| Lookups | `claude-haiku-5-5` | default |
| Code mapping, mechanical edits | `claude-sonnet-5-5` | low |
| Builder | `claude-opus-5-5` | medium |
| Reviewer | Codex `gpt-6.1-sol` | high, read-only |

Design, review triage and small fixes stay with the coordinator. The reviewer is always from the other family than the author, so GPT-written work goes to `claude-opus-5-5` at high. The full table and the fallbacks are in each set's `agent-run/SKILL.md`.

## Launching a run

Each run uses the first launcher that can run its model:

1. T3 `delegate_task`, when the session is a T3 Code thread and has the tool.
2. The host's own subagent tool, for a model of the host's family (Claude Code's `Agent` tool for Claude models, Codex's subagent tool for GPT models).
3. `bin/agent-run`, the script, for everything else. It runs Claude or Codex as builder or reviewer, resumable by session, and picks the model from the agent and role you pass. Override with `--model` and `--effort`, or with `AGENT_RUN_<CLAUDE|CODEX>_<BUILDER|REVIEWER>_MODEL`. `--timeout` caps a turn and `agent-run wait` blocks until a run stops.

The two sets differ only in the host subagent section and host notes. When you change shared wording (review lenses, plan contract, templates, specs), change both sets.

## Per project

Each repo may add `.agents/build.md` (roles, gates, builder fences, how to run the app). See `writing-plans/references/project.md` in either set. Without it, `writing-plans` reads `AGENTS.md`/`CLAUDE.md`, discovers the rest, and proposes the file.

## Per machine

Wrap a CLI for one machine (gateway, env swap) with an executable `~/.config/agent-run/codex` or `~/.config/agent-run/claude`.
