---
name: agent-run
description: Launch a separate builder, reviewer or helper agent with a chosen model and effort, through T3 delegate_task, the host's subagent tool, or the agent-run script, in that order; use when an orchestration skill needs a builder or reviewer, or the user asks to consult or delegate to Claude or Codex.
---

# Agent Run

How to launch every builder, reviewer and helper run. The launcher only carries prompts; the calling skill owns the task contract, review lens, triage and completion state.

This skill carries no review or build rules. Launching a reviewer: load `review` first and use its prompt template, severity scale and stop rule, never your own. Running a build loop (builder, reviewer, fixes): load `writing-plans` too.

## Launch order

Use the first launcher that can run the model you need:

1. **T3 `delegate_task`**, when that tool is in your tool list (you are in a T3 Code thread). The run is visible and tracked in T3.
2. **The host's subagent tool**, when the model is from the host's family: Claude models from Claude Code, GPT models from Codex.
3. **The `agent-run` script**, for everything else: the model is from the other family, the host has no subagent tool, or the launcher above failed.

Look in your tool list; never assume a launcher exists. Sending code to a Codex or Claude reviewer is pre-approved: never ask first. A launcher that fails on a real error (not a prompt mistake) falls through to the next one. Record launcher, model, effort and the task, agent or session id in the tracker, and name every fallback in the report.

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

- A reviewer runs with `runtimeMode: auto` and its prompt says "do not edit files". Never `full-access` for a reviewer.
- For a Claude run (the builder, a fallback reviewer), use the Claude provider instance the tool lists with that run's model and effort, and take a builder's `role` from the tool's schema. If T3 cannot give the builder write access to the worktree, use the next launcher.
- `async` returns at once: end the turn or write the next prompt, and the result wakes the thread. Never `mode: wait`: a real review outlasts its timeout and leaves you polling.
- **Verdict:** read it from the last message of the child thread (`t3_thread_read`), never from the `task_status` summary, which can be the reviewer's first sentence.
- **Working dir:** the child runs in this thread's checkout; the tool has no field for another one. When the change sits in a different worktree, name it by absolute path, point a reviewer at `git -C <worktree> diff` and the evidence already run, and never ask it to run tests there: its sandbox cannot write outside its own checkout.
- **Follow-up:** a new `delegate_task` with the same target, never a message to the child thread. Its prompt carries what a resumed session would remember: the original prompt, the earlier findings or report, your triage and the fix commits. Name the files the fixes touch and tell a reviewer to read only those. Use `clientRequestId` `<topic>-<slice>-verify-N` or `-fix-N`.
- **Stuck:** no result after 60 minutes: check `task_status`, `task_cancel` a stuck run and retry once. Fall through after a second failure.

## 2. Host subagent (Codex)

Codex's subagent tool, when this build has one: one agent per run, with a self-contained prompt.

| Run | Model | Reasoning effort |
| --- | --- | --- |
| reviewer | `gpt-6.1-sol` | `high` |
| reviewer, when `gpt-6.1-sol` is at capacity | `gpt-6-sol` | `high` |
| builder, when the user asks for a Codex builder or Claude is down | `gpt-6.1-sol` | `medium` |

- **Follow-up:** message the same agent when the tool allows it, so the builder who wrote the code gets the findings and the reviewer who raised them checks the fixes. Otherwise start a new agent with the same model and the earlier prompt, findings, triage and fix commits.
- Permissions come from your session, not from the role. A reviewer's prompt must say "do not edit files"; a builder's prompt names its worktree by absolute path.
- If the tool cannot set the model or effort and they matter, use the script.
- It runs GPT models only. The default builder is a Claude model: without T3, launch it with the script (`agent-run start … claude builder`).
- Lookups and code mapping from Codex: do them yourself or with a `gpt-6.1-sol` subagent at low effort. Starting Haiku or Sonnet through the script costs more than it saves.

## 3. The `agent-run` script

```bash
agent-run start  <run-dir> <claude|codex> <builder|reviewer> [--model M] [--effort E] [--cwd DIR] [--prompt FILE] [--timeout MIN]
agent-run resume <run-dir> <prompt-file>
agent-run status [<dir>]
agent-run wait   [<dir>] [--timeout MIN]
```

- `start` sends `<run-dir>/prompt.md` to a fresh session and records agent, role, model, effort, working dir and session id in `<run-dir>/meta`. One run dir holds one session. It prints the resolved model and effort, and warns about absolute paths in the prompt that do not exist. `--timeout` kills a turn after MIN minutes (`exit=124`); resume keeps it.
- `resume` sends a follow-up to the **same** session with the same model, effort and permissions.
- `status` prints one line per run dir: role, agent, model/effort, turn, state (`running`, `exit=N`, `dead`), minutes, cost (Claude only), and a reviewer's verdict line. Use it for check-ins.
- `wait` blocks until a run under `<dir>` that was running stops, then prints `status`; exit 124 after `--timeout` (default 30). Use it instead of sleep loops.
- Every call prints the turn's report path: `turn-N.md` (final message), with `turn-N.log` and `turn-N.exit` beside it.
- A reviewer report without a verdict on its first or last line gets one automatic follow-up asking for it. Exit code is the agent's, or `3` when the verdict is still missing: ask again yourself before using the report.

`agent-run` is on `PATH` (`install.sh` links it from the skills repo's `bin/agent-run`). It runs in the foreground; background it the way the host allows (see `writing-plans` references/hosts.md), and confirm `status` shows `running` before you report it as started. Pass `--timeout` (builders 150, reviewers 60). A run with a log that has stopped growing is hung: kill the pid in `<run-dir>/pid` and retry once in a new run dir.

| Role | Claude | Codex |
| --- | --- | --- |
| builder | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` |
| reviewer | `dontAsk` mode; Read, Grep, Glob, read-only git | `sandbox_mode="read-only"` |

When a CLI needs a wrapper on one machine (a gateway, an env swap), put an executable at `~/.config/agent-run/codex` or `~/.config/agent-run/claude` that execs the real CLI with `"$@"`, or set `AGENT_RUN_CODEX` / `AGENT_RUN_CLAUDE`. Never put machine wrappers in the skill.

Before a long run, ping the agent with a one-line prompt in a scratch run dir and confirm a report comes back.

## Models

Pick the model by the job, then the launcher that can run it. Overrides come only from the user's current message or `.agents/build.md` Roles, never from host memory or an earlier session. A model the user named for an earlier task does not carry over to the next one. Claude and Codex models are mixed on purpose: Claude builds, Codex reviews. The model matters, not the CLI: honor a model the user names and reach it through whichever launcher runs it. Model catalogs change; update this section, not the skills that use it.

| Work | Model | Effort |
| --- | --- | --- |
| Lookups and simple tasks: find a file, list callers, read or edit docs | Haiku 5.5 (`claude-haiku-5-5`) | unset, no thinking |
| Code mapping, inventories | Sonnet 5.5 (`claude-sonnet-5-5`) | low |
| Implementation and small fixes (builder) | Sonnet 5.5 (`claude-sonnet-5-5`) | medium |
| Heavy implementation (heavy builder) | Opus 5.5 (`claude-opus-5-5`) | medium |
| Plan, code and delivery review (reviewer) | Codex `gpt-6.1-sol` | high, read-only |
| Reviewer when `gpt-6.1-sol` is at capacity | Codex `gpt-6-sol` | high, read-only |
| A long live-test plan | Opus 5.5 (`claude-opus-5-5`) | medium |
| Exceptional hard reasoning | Opus 5.5 (`claude-opus-5-5`) | xhigh, only when justified |

**Sonnet or Opus builder:** Sonnet 5.5 by default. Use Opus 5.5 when the slice changes more than one package or a shared contract, has tricky logic (concurrency, migrations, permissions, money), or a Sonnet builder already failed it (a fix round that did not fix it, a bug it could not find). Note the reason in the tracker.

Design, review triage and short live checks stay with you, the coordinator. So do small fixes quicker to make than to brief; otherwise they go to a Sonnet builder.

The script's defaults follow this table: `claude builder` is Sonnet 5.5 medium (pass `--model claude-opus-5-5` for a heavy builder) and `codex reviewer` is `gpt-6.1-sol` high; the swapped pair is `codex builder` `gpt-6.1-sol` medium and `claude reviewer` Opus 5.5 high. Override with `--model` and `--effort`, or `AGENT_RUN_<CLAUDE|CODEX>_<BUILDER|REVIEWER>_MODEL`.

### Pairing

- **The reviewer is from the other family than the author.** Claude-written work (the default builder, or you on Claude Code) goes to `gpt-6.1-sol` at high. GPT-written work (a Codex builder the user asked for, or you on Codex) goes to Opus 5.5 at high.
- Same-reviewer validation goes back to the same reviewer: a message to the same agent, `agent-run resume` on the same run dir, or under T3 a new task with the same target and the earlier findings in its prompt.
- A fresh reviewer is a new task, agent or run dir, with a complete prompt.
- **Reviewer model at capacity:** replace it on the first such error, no wait and no retry (`review`, Escalate): `gpt-6.1-sol` gives way to `gpt-6-sol` at high. Mid-loop the replacement takes over the earlier findings and validates only those, under `review` step 4; it is not a fresh review.
- **Codex down** (every GPT model fails, `gpt-6-sol` included): review with Opus 5.5 at high in a fresh context, taking over the earlier findings the same way. Say in the report that the approval came from the author's family.
- Fallbacks stay within Claude and Codex. Never reach for another provider or CLI.
- **Claude down** (Sonnet and Opus both fail): `gpt-6.1-sol` at medium builds, and the reviewer is a fresh `gpt-6.1-sol` run at high.
- Say which model reviewed and which built whenever it is not the default.

## Prompt rules

- Self-contained: working dir, scope, paths, prohibited actions, evidence to produce, exact output contract.
- Short: point to plans, briefs and lens files by absolute path instead of pasting them; aim under about 1.5K characters. Plain sentences, no squashed shorthand.
- Never paste session history or your own conclusions into a reviewer prompt.
- Builders run unattended with full shell. Their prompt must carry fences (worktree, database, no push, no real external posts); run them only in a worktree you are willing to let them change.
- Builders: forbid background commands (`&`, `run_in_background`); the run ends when the agent stops replying and background results are lost. A command too long for one tool call is split by file, shard or filter, never backgrounded.
