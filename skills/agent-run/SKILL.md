---
name: agent-run
description: Run Claude Code or Codex as a separate builder or reviewer process with a chosen model and effort, resumable by session; use when an orchestration skill needs another model family, or the user asks to consult or delegate to Claude or Codex.
---

# Agent Run

`scripts/agent-run` is the transport for every cross-model run. It only carries prompts; the calling skill owns the task contract, review lens, triage and completion state.

## Commands

```bash
agent-run start  <run-dir> <claude|codex> <builder|reviewer> [--model M] [--effort E] [--cwd DIR] [--prompt FILE]
agent-run resume <run-dir> <prompt-file>
agent-run status [<dir>]
```

- `start` sends `<run-dir>/prompt.md` to a fresh session and records agent, role, model, effort, working dir and session id in `<run-dir>/meta`. One run dir holds one session.
- `resume` sends a follow-up to the **same** session with the same model, effort and permissions. Use it to return review findings to the builder who wrote the code, and fixes to the reviewer who raised the findings.
- `status` prints one line per run dir: role, agent, model/effort, turn, state (`running`, `exit=N`, `dead`), minutes, cost (Claude only), and a reviewer's verdict line. Use it for check-ins.
- Every call prints the turn's report path: `turn-N.md` (final message), with `turn-N.log` and `turn-N.exit` beside it.
- Exit code is the agent's, or `3` when a reviewer's report does not end with a verdict line. Resume that reviewer and ask for the verdict before using the report.

Path: `<skill dir>/scripts/agent-run`. The script runs in the foreground; background it the way the host allows (see `writing-plans` references/hosts.md).

## Roles and permissions

| Role | Claude | Codex |
| --- | --- | --- |
| builder | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` |
| reviewer | `dontAsk` mode; Read, Grep, Glob, read-only git | `sandbox_mode="read-only"` |

Builders run unattended with full shell, so their prompt must carry fences (worktree, database, no push, no real external posts). Run builders only in a worktree you are willing to let them change.

## Models

Honor a model the user names. Default: Claude `opus` (`AGENT_RUN_CLAUDE_MODEL`), Codex `gpt-6.1-sol` (`AGENT_RUN_CODEX_MODEL`); effort `medium` for builders, `high` for reviewers. State every fallback in the report. Model catalogs change; update this section, not the skills that use it.

### Codex

| Work | Model | Effort |
| --- | --- | --- |
| Mechanical edits, lookups | `gpt-6.1-sol` | low |
| Implementation | `gpt-6.1-sol` | medium |
| Code, plan or architecture review | `gpt-6.1-sol` | high |
| Exceptional hard reasoning | `gpt-6.1-sol` | xhigh, only when justified |

### Claude

| Work | Model | Effort |
| --- | --- | --- |
| Mechanical edits | `sonnet` | low |
| Implementation | `opus` | medium |
| Review | `opus` | high |
| Hard design or plan review | `fable` | high |

### Pairing

- Builder and reviewer come from different families by default: Claude builds, Codex reviews, or the reverse. Different families miss different bugs.
- Same-reviewer validation keeps the same run dir, so the same model and session.
- A fresh reviewer is a new run dir.
- If a family is down, use the other family's strongest model or a native subagent, and say which one you used.

## Machine setup

When a CLI needs a wrapper on one machine (a gateway, an env swap), put an executable at `~/.config/agent-run/codex` or `~/.config/agent-run/claude` that execs the real CLI with `"$@"`, or set `AGENT_RUN_CODEX` / `AGENT_RUN_CLAUDE`. Never put machine wrappers in the skill.

Before a long run, ping each agent with a one-line prompt in a scratch run dir and confirm a report comes back.

## Prompt rules

- Self-contained: working dir, scope, paths, prohibited actions, evidence to produce, exact output contract.
- Never paste session history or your own conclusions into a reviewer prompt.
- Builders: forbid background commands (`&`, `run_in_background`); the process ends when the agent stops replying and background results are lost.
