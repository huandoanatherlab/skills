# Skills repo

Personal plan, build and review skills for T3 Code. See [README.md](README.md) for the layout, models and flow.

## Git

- Commit straight to `main`. Never create a branch or open a PR here unless asked.
- Commit only when asked; never push unless asked.

## Editing skills

- `claude/` is one Claude Code plugin (`ath`): skills under `claude/skills/<name>/`. T3's Claude provider loads it with launch argument `--plugin-dir <repo>/claude`, so an edit is live in the next T3 thread. Nothing is linked into `~/.claude/skills` or `~/.codex/skills`.
- Every skill starts with the T3 guard line; keep it.
- Model names live in `claude/skills/agent-run/SKILL.md` (Models), the script defaults in `bin/agent-run`, and the summary in `README.md`. Keep the three in step.
- Never put machine-specific wrappers or paths (gateways, binaries) in a skill; they belong in `~/.config/agent-run/` or T3's provider settings.
