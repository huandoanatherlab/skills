# Skills

Plan, build and review skills shared by Claude Code and Codex. One source, linked into both.

```bash
./install.sh --dry-run
./install.sh
```

`install.sh` links each `skills/<name>` into `~/.claude/skills` and `~/.codex/skills`, links `agent-run` into `~/.local/bin`, and moves anything it replaces to `~/.skills-backup/<time>/`.

## Flow

```
writing-specs (optional) → writing-plans: plan ─review(plan)→ build ─review(code)→ review(delivery)
                                                                 └─ agent-run: Claude ⇄ Codex
```

| Skill | Job |
| --- | --- |
| `writing-plans` | Plan (slices, live proof, risk), get it reviewed, then build it as coordinator with Sonnet 5.5 builders and Opus 5.5 reviewers |
| `review` | Review loop with triage and same-reviewer approval; lenses: plan, code, delivery |
| `agent-run` | Script to run Claude (Sonnet 5.5 builds, Opus 5.5 reviews) or Codex as builder or reviewer, resumable by session |
| `writing-specs` | Lasting product (PRD) and design (TDD) docs in `docs/` |

## Per project

Each repo may add `.agents/build.md` (roles, gates, builder fences, how to run the app). See `skills/writing-plans/references/project.md`. Without it, `writing-plans` reads `AGENTS.md`/`CLAUDE.md`, discovers the rest, and proposes the file.

## Per machine

Wrap a CLI for one machine (gateway, env swap) with an executable `~/.config/agent-run/codex` or `~/.config/agent-run/claude`.
