# Roles

The skills hand work to three roles, so the agent that coordinates keeps its own context small and never reviews its own work:

| Role | File | Does |
| --- | --- | --- |
| `ath-builder` | [builder.md](builder.md) | Implements one slice, proves it against its acceptance checks, commits, reports |
| `ath-reviewer` | [reviewer.md](reviewer.md) | Read-only, skeptical review with a lens: plan, slice or final |
| `ath-scout` | [scout.md](scout.md) | Cheap read-only lookups and code mapping |

## Spawn a role

- **Claude Code:** the files are installed as agents in `~/.claude/agents/`. Use the Agent tool with `subagent_type: ath-<role>`, foreground, and a `name` (`S03-build`, `S03-review`) so you can continue it later. The agent file sets its model, effort and tools.
- **Another agent with sub-agents (Codex and others):** spawn a sub-agent whose task starts with "Read `<absolute path to this folder>/<role>.md` and act as that role." Then add the brief. For the reviewer, also say "do not edit files". Use a strong model for the reviewer and a cheaper one for the scout when the harness lets you choose.
- **No sub-agents:** do the builder's work yourself. Then review in a separate pass: re-read `reviewer.md`, read only the diff and the plan, and write the findings before you fix anything. Record "self-reviewed" in the progress file.

## Continue a role

Fix and verify rounds go to the **same** builder or reviewer, so it keeps its context:
- **Claude Code:** `SendMessage` to its name. Its reply arrives as a notification: do other independent work, or end the turn, and the reply wakes you.
- **Elsewhere:** resume the sub-agent if the harness can. Otherwise spawn it again with its previous report plus the new message.
