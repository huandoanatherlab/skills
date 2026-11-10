# Skills repo

Personal plan, build, review, debug, docs and cleanup skills. See [README.md](README.md) for the layout, models and flow.

## Git

- Commit straight to `main`. Never create a branch or open a PR here unless asked.
- Commit only when asked; never push unless asked.

## Editing skills

- Each skill is a plain Agent Skills folder: `skills/ath-<name>/SKILL.md` plus `references/`, `scripts/` or `roles/`. `install.sh` links them into `~/.claude/skills` and `~/.agents/skills`, and the roles into `~/.claude/agents`.
- **Portable first.** A skill must work in plain Claude Code and in other agents such as Codex. Use these patterns:
  - Mark tool-specific steps: *T3* for `mcp__t3-code__*` tools, "Claude Code" for the Agent tool and `SendMessage`. Give a fallback for everything else.
  - Reference a skill's own files by relative path. For scripts, add `${CLAUDE_SKILL_DIR}` as the Claude Code hint.
- Skill names carry the `ath-` prefix so they never collide with built-in commands.
- Model names live in the role frontmatter (`skills/ath-execute/roles/*.md`) and in the Models table in `README.md`. Keep the two in step.
- Keep skills short and generic: no project names, no per-repo config files. Project specifics come from the target repo's `AGENTS.md` and `docs/`.
- Scripts must run on macOS bash 3.2 and Git Bash on Windows.
- Never put machine-specific wrappers or paths in a skill.
