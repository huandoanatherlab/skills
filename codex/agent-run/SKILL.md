---
name: agent-run
description: Launch a separate builder, reviewer or helper agent with a chosen model and effort, through T3 delegate_task, the host's subagent tool, or the agent-run script, in that order; use when an orchestration skill needs a builder or reviewer, or the user asks to consult or delegate to Codex or Claude.
---

# Agent Run

How to launch every builder, reviewer and helper run. The launcher only carries prompts; the calling skill owns the task contract, review lens, triage and completion state.

## Launch order

Use the first launcher that can run the model you need:

1. **T3 `delegate_task`**, when that tool is in your tool list (you are in a T3 Code thread). The run is visible and tracked in T3.
2. **The host's subagent tool**, when the model is from the host's family: GPT models from Codex, Claude models from Claude Code.
3. **The `agent-run` script**, for everything else: the model is from the other family, the host has no subagent tool, or the launcher above failed.

Look in your tool list; never assume a launcher exists. A launcher that fails on a real error (not a prompt mistake) falls through to the next one. Record launcher, model, effort and the task, agent or session id in the tracker, and name every fallback in the report.

Whatever the launcher, the run dir is the record. Write `<run-dir>/prompt.md` first and send that text; save each reply as `<run-dir>/turn-N.md` (the script does both itself). When the script did not run a reviewer, check its last line for the verdict yourself and ask again if it is missing.

## 1. T3 `delegate_task`

Known-good review call:

| Field | Value |
| --- | --- |
| target | `providerInstanceId: codex`, `model: gpt-6.1-sol`, option `reasoningEffort: high` |
| `role` | `review` |
| `mode` | `async` |
| `runtimeMode` | `auto` |
| `clientRequestId` | `<topic>-<slice>-review-1`, unique per call |

- For a Claude run (the builder, a fallback reviewer), use the Claude provider instance the tool lists with that run's model and effort, and take a builder's `role` from the tool's schema. If T3 cannot give the builder write access to the worktree, use the next launcher.
- `async` returns at once: end the turn or write the next prompt, and the result wakes the thread.
- **Follow-up:** a new `delegate_task` with the same target, never a message to the child thread. Its prompt carries what a resumed session would remember: the original prompt, the earlier findings or report, your triage and the fix commits. Use `clientRequestId` `<topic>-<slice>-verify-N` or `-fix-N`.
- **Stuck:** no result after 60 minutes: check `task_status`, `task_cancel` a stuck run and retry once. Fall through after a second failure.

## 2. Host subagent (Codex)

Codex's subagent tool, when this build has one: one agent per run, with a self-contained prompt.

| Run | Model | Reasoning effort |
| --- | --- | --- |
| reviewer | `gpt-6.1-sol` | `high` |
| builder, when the user asks for a Codex builder or Claude is down | `gpt-6.1-sol` | `medium` |

- **Follow-up:** message the same agent when the tool allows it, so the builder who wrote the code gets the findings and the reviewer who raised them checks the fixes. Otherwise start a new agent with the same model and the earlier prompt, findings, triage and fix commits.
- Permissions come from your session, not from the role. A reviewer's prompt must say "do not edit files"; a builder's prompt names its worktree by absolute path.
- If the tool cannot set the model or effort and they matter, use the script.
- It runs GPT models only. The default builder is a Claude model: without T3, launch it with the script (`agent-run start … claude builder`).
- Lookups and code mapping from Codex: do them yourself or with a `gpt-6.1-sol` subagent at low effort. Starting Haiku or Sonnet through the script costs more than it saves.

## 3. The `agent-run` script

```bash
agent-run start  <run-dir> <claude|codex> <builder|reviewer> [--model M] [--effort E] [--cwd DIR] [--prompt FILE]
agent-run resume <run-dir> <prompt-file>
agent-run status [<dir>]
```

- `start` sends `<run-dir>/prompt.md` to a fresh session and records agent, role, model, effort, working dir and session id in `<run-dir>/meta`. One run dir holds one session.
- `resume` sends a follow-up to the **same** session with the same model, effort and permissions.
- `status` prints one line per run dir: role, agent, model/effort, turn, state (`running`, `exit=N`, `dead`), minutes, cost (Claude only), and a reviewer's verdict line. Use it for check-ins.
- Every call prints the turn's report path: `turn-N.md` (final message), with `turn-N.log` and `turn-N.exit` beside it.
- Exit code is the agent's, or `3` when a reviewer's report does not end with a verdict line. Resume that reviewer and ask for the verdict before using the report.

`agent-run` is on `PATH` (`install.sh` links it from the skills repo's `bin/agent-run`). It runs in the foreground; background it the way the host allows (see `writing-plans` references/hosts.md), and confirm `status` shows `running` before you report it as started. A run past 60 minutes with a log that has stopped growing is hung: kill the pid in `<run-dir>/pid` and retry once in a new run dir.

| Role | Claude | Codex |
| --- | --- | --- |
| builder | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` |
| reviewer | `dontAsk` mode; Read, Grep, Glob, read-only git | `sandbox_mode="read-only"` |

When a CLI needs a wrapper on one machine (a gateway, an env swap), put an executable at `~/.config/agent-run/codex` or `~/.config/agent-run/claude` that execs the real CLI with `"$@"`, or set `AGENT_RUN_CODEX` / `AGENT_RUN_CLAUDE`. Never put machine wrappers in the skill.

Before a long run, ping the agent with a one-line prompt in a scratch run dir and confirm a report comes back.

## Models

Pick the model by the job, then the launcher that can run it. Claude and Codex models are mixed on purpose: Claude builds, Codex reviews. The model matters, not the CLI: honor a model the user names and reach it through whichever launcher runs it. Model catalogs change; update this section, not the skills that use it.

| Work | Model | Effort |
| --- | --- | --- |
| Lookups: find a file, list callers | Haiku 5.5 (`claude-haiku-5-5`) | default |
| Code mapping, inventories, mechanical edits | Sonnet 5.5 (`claude-sonnet-5-5`) | low |
| Implementation (builder) | Opus 5.5 (`claude-opus-5-5`) | medium |
| Plan, code and delivery review (reviewer) | Codex `gpt-6.1-sol` | high, read-only |
| A long live-test plan | Opus 5.5 (`claude-opus-5-5`) | medium |
| Exceptional hard reasoning | Opus 5.5 (`claude-opus-5-5`) | xhigh, only when justified |

Design, review triage, small fixes and short live checks stay with you, the coordinator.

The script's defaults follow this table: `claude builder` is Opus 5.5 medium and `codex reviewer` is `gpt-6.1-sol` high; the swapped pair is `codex builder` `gpt-6.1-sol` medium and `claude reviewer` Opus 5.5 high. Override with `--model` and `--effort`, or `AGENT_RUN_<CLAUDE|CODEX>_<BUILDER|REVIEWER>_MODEL`.

### Pairing

- **The reviewer is from the other family than the author.** Claude-written work (the default builder, or you on Claude Code) goes to `gpt-6.1-sol` at high. GPT-written work (a Codex builder the user asked for, or you on Codex) goes to Opus 5.5 at high.
- Same-reviewer validation goes back to the same reviewer: a message to the same agent, `agent-run resume` on the same run dir, or under T3 a new task with the same target and the earlier findings in its prompt.
- A fresh reviewer is a new task, agent or run dir, with a complete prompt.
- **Codex down, or at capacity twice:** review with Opus 5.5 at high in a fresh context.
- Fallbacks stay within Claude and Codex. Never reach for another provider or CLI.
- **Claude down:** `gpt-6.1-sol` at medium builds, and the reviewer is a fresh `gpt-6.1-sol` run at high.
- Say which model reviewed and which built whenever it is not the default.

## Prompt rules

- Self-contained: working dir, scope, paths, prohibited actions, evidence to produce, exact output contract.
- Never paste session history or your own conclusions into a reviewer prompt.
- Builders run unattended with full shell. Their prompt must carry fences (worktree, database, no push, no real external posts); run them only in a worktree you are willing to let them change.
- Builders: forbid background commands (`&`, `run_in_background`); the run ends when the agent stops replying and background results are lost.
