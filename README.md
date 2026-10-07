# Skills

Plan, build and review skills shared by Claude Code and Codex. One source, linked into both.

```bash
./install.sh --dry-run
./install.sh
```

`install.sh` links each `skills/<name>` into `~/.claude/skills` and `~/.codex/skills`, links `agent-run` into `~/.local/bin`, and moves anything it replaces to `~/.skills-backup/<time>/`.

## Flow

```
writing-prd → writing-tdd → writing-plans ──plan-review──▶ build-plan ──code-quality-review──▶ verify-plan-delivery
                                   (thermal-review-loop)       │  (thermal-review-loop)
                                                               └─ agent-run: Claude ⇄ Codex
```

| Skill | Job |
| --- | --- |
| `writing-plans` | Plan with slice IDs, file ownership, live proof level and risk per slice |
| `plan-review` | Lens for plans |
| `build-plan` | Coordinator: builders from one model family, reviewers from the other, triage, a commit per slice, live check |
| `agent-run` | Script to run Claude or Codex as builder or reviewer, resumable by session |
| `thermal-review-loop` | Review, triage, fix, same-reviewer approval; a fresh reviewer only for risky targets and the final diff |
| `code-quality-review` | Lens for code |
| `verify-plan-delivery` | Acceptance audit against the plan, including live proof |
| `writing-prd`, `writing-tdd` | Product and technical design docs |

## Per project

Each repo may add `.agents/build.md` (roles, gates, builder fences, how to run the app). See `skills/build-plan/references/project-config.md`. Without it, `build-plan` reads `AGENTS.md`/`CLAUDE.md`, discovers the rest, and proposes the file.

## Per machine

Wrap a CLI for one machine (gateway, env swap) with an executable `~/.config/agent-run/codex` or `~/.config/agent-run/claude`. Model defaults live in `skills/agent-run/references/models.md`.
