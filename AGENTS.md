# Skills repo

Personal plan, build and review skills. See [README.md](README.md) for the layout, models and launch order.

## Git

- Commit straight to `main`. Never create a branch or open a PR here unless asked.
- Commit only when asked; never push unless asked.

## Editing skills

- `claude/` and `codex/` differ only in the host subagent section of `agent-run`, in `writing-plans/references/hosts.md`, and in the Codex-only `systematic-debugging/agents/openai.yaml`. Change shared wording in both sets; `diff -r claude codex` must show only those host parts.
- Model names and fallbacks live in `agent-run/SKILL.md`, the defaults in `bin/agent-run`, and the summary in `README.md`. Keep the three in step.
- Skills are symlinked from this working tree (`install.sh`), so an edit is live at once.
