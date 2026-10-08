# Skills

Plan, build and review skills, with one set for Claude Code and one for Codex. Each set uses its own host's models.

```bash
./install.sh --dry-run
./install.sh
```

`install.sh` links each `claude/<name>` into `~/.claude/skills` and each `codex/<name>` into `~/.codex/skills`. It links `bin/agent-run` into `~/.local/bin`, and moves anything it replaces to `~/.skills-backup/<time>/`.

## Flow

```
writing-specs (optional) → writing-plans: plan ─review(plan)→ build ─review(code)→ review(delivery)
                                                                 └─ agent-run: builder and reviewer runs
```

| Skill | Job |
| --- | --- |
| `writing-plans` | Plan (slices, live proof, risk), get it reviewed, then build it as coordinator with builder and reviewer runs |
| `review` | Review loop with triage and same-reviewer approval; lenses: plan, code, delivery |
| `agent-run` | Model defaults for this host; the shared `bin/agent-run` script runs Claude or Codex as builder or reviewer, resumable by session |
| `writing-specs` | Lasting product (PRD) and design (TDD) docs in `docs/` |

## Models

| Set | Builder | Reviewer |
| --- | --- | --- |
| `claude/` | `claude-sonnet-5-5`, medium | `claude-opus-5-5`, high |
| `codex/` | `gpt-6.1-sol`, medium | `gpt-6-astra`, medium |

`bin/agent-run` picks these from the agent and role you pass. Override them with `--model` and `--effort`, or with `AGENT_RUN_<CLAUDE|CODEX>_<BUILDER|REVIEWER>_MODEL`.

The two sets differ only in model names and host notes. When you change shared wording (review lenses, plan contract, templates, specs), change both sets.

## Per project

Each repo may add `.agents/build.md` (roles, gates, builder fences, how to run the app). See `writing-plans/references/project.md` in either set. Without it, `writing-plans` reads `AGENTS.md`/`CLAUDE.md`, discovers the rest, and proposes the file.

## Per machine

Wrap a CLI for one machine (gateway, env swap) with an executable `~/.config/agent-run/codex` or `~/.config/agent-run/claude`.
