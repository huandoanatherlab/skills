---
name: agent-run
description: Launch a builder, reviewer or helper sub-agent in T3 with a chosen model and effort through delegate_task, and follow it to a result; use when an orchestration skill needs a builder or reviewer, or the user asks to consult or delegate to Claude or a GPT model.
---

# Agent Run

T3 Code only: without `mcp__t3-code__*` tools, say this skill runs in T3 and stop.

How to launch every builder, reviewer and helper run. The launcher only carries prompts; the calling skill owns the task contract, review lens, triage and completion state.

This skill carries no review or build rules. Launching a reviewer: load `review` first and use its prompt template, severity scale and stop rule, never your own. Running a build loop: load `lane-build` too.

## Launch

Every run is a T3 `delegate_task`. The run is a child thread of yours, visible and tracked in T3. Sending code to a reviewer is pre-approved: never ask first. Record model, effort, `clientRequestId` and `taskId` in the tracker.

The run dir is the record. Write `<run-dir>/prompt.md` first and send that text; save the child's final message as `<run-dir>/turn-N.md`.

| Field | Value |
| --- | --- |
| `target` | `providerInstanceId` and `model` from `orchestrator_capabilities`; effort in `options`: `effort` for `claudeAgent`, `reasoningEffort` for `codex` |
| `role` | `review`, `implementation`, `research` or `test` |
| `mode` | `async` |
| `runtimeMode` | reviewer `auto`; builder and helper leave it unset (inherit) |
| `isolation` | `shared` (default): the child works in your checkout. `worktree`: a new checkout from your local HEAD, for a builder that runs in parallel with another in the same lane |
| `clientRequestId` | `<topic>-<slice>-<build|review|verify|fix>-N`, unique per call, stable across retries of that call |
| `title` | short: `<slice> review 1` |

- A reviewer's prompt says "do not edit files". Never `full-access` for a reviewer.
- `async` returns at once: end the turn or write the next prompt; the result wakes the thread. Never `mode: wait`: a real review outlasts its timeout.
- **Working dir:** a lane thread's checkout is the lane worktree, so `shared` children work there. An `isolation: worktree` child gets its own `t3/*` branch and checkout: list both under Resources, merge its commits into your branch when it passes review, then remove that checkout and branch.
- **Verdict:** read it from the child's last message (`t3_thread_read` on `childThreadId`), never from the `task_status` summary, which can be the reviewer's first sentence.
- **Questions:** `task_status` shows `hasPendingQuestion`: read it with `t3_pending_request_list`/`_read` on the child thread and answer with `t3_pending_request_respond`, or ask the user.
- **Follow-up:** a new `delegate_task` with the same target, never a message to the child thread. Its prompt carries what a resumed session would remember: the original prompt, the earlier findings or report, your triage and the fix commits. Name the files the fixes touch and tell a reviewer to read only those.
- **Before relaunching anything:** check `task_status` of the earlier run. `interrupted` is not failure: a T3 or provider restart can mark finished runs interrupted. Read the child's last output first and use it if it is complete.
- **Lost wake-ups:** a completion can fail to wake you. Before ending a turn with runs in flight, make sure a safety net exists: the master's health check (`orchestrate`), or for a solo build one interval `schedule_task` (`lane-build`). On `parent_not_active`, retry the launch from that check, not in the same turn.
- **Stuck:** no result after 60 minutes: check `task_status`, `task_cancel` a stuck run and retry once; then stop that slice and ask (Pairing).

### GPT models

Only when the user names one for the task. Use `providerInstanceId: codex` with that model and `reasoningEffort`. The machine routes the codex instance through its own binary (on this user's machine, the ai-gateway launcher), so:

- Provider health is what `orchestrator_capabilities` says: a model in the list with no `constraints` can run. Never diagnose with `codex login status`, never edit `~/.codex/config.toml`, never assume Codex is logged out.
- A run that fails on auth or gateway errors gets one retry, then ask the user.

### Fallback: the `agent-run` script

Only when T3 cannot launch the model (not listed, or `delegate_task` itself fails twice on a real error). The script runs Claude or Codex as builder or reviewer in the foreground, resumable by session:

```bash
agent-run start  <run-dir> <claude|codex> <builder|reviewer> [--model M] [--effort E] [--cwd DIR] [--prompt FILE] [--timeout MIN]
agent-run resume <run-dir> <prompt-file>
agent-run status [<dir>]
agent-run wait   [<dir>] [--timeout MIN]
```

Start it with the Bash tool's `run_in_background`, pass `--timeout` (builders 150, reviewers 60), and confirm `status` shows `running`. A machine wrapper for a CLI lives at `~/.config/agent-run/<codex|claude>`, never in the skill. Name the fallback in the report.

## Models

Pick the model by the job. Overrides come only from the user's current message or `.agents/build.md` Roles, never from host memory or an earlier session. A model the user named for an earlier task does not carry over to the next one. Every run uses a Claude model: Claude builds and Claude reviews. A GPT model runs only when the user names one for that task. Model catalogs change; update this section, not the skills that use it.

| Work | Model | Effort |
| --- | --- | --- |
| Lookups and simple tasks: find a file, list callers, read or edit docs | Haiku 5.5 (`claude-haiku-5-5`) | unset, no thinking |
| Code mapping, inventories | Sonnet 5.5 (`claude-sonnet-5-5`) | low |
| Implementation and small fixes (builder) | Sonnet 5.5 (`claude-sonnet-5-5`) | medium |
| Heavy implementation (heavy builder) | Opus 5.5 (`claude-opus-5-5`) | medium |
| Review of a simple target: docs, config, a short plan, a small `normal`-risk diff in one package | Haiku 5.5 (`claude-haiku-5-5`) | high, read-only |
| Review of a medium target: a `normal`-risk code slice, a feature plan | Opus 5.5 (`claude-opus-5-5`) | medium, read-only |
| Review of a complex target: a `risky` slice (migration, shared contract, permissions, concurrency, money, more than one package), a milestone plan, the whole-diff review, the delivery audit | Opus 5.5 (`claude-opus-5-5`) | high, read-only |
| A long live-test plan | Opus 5.5 (`claude-opus-5-5`) | medium |
| Exceptional hard reasoning | Opus 5.5 (`claude-opus-5-5`) | xhigh, only when justified |

**Sonnet or Opus builder:** Sonnet 5.5 by default. Use Opus 5.5 when the slice changes more than one package or a shared contract, has tricky logic (concurrency, migrations, permissions, money), or a Sonnet builder already failed it (a fix round that did not fix it, a bug it could not find). Note the reason in the tracker.

**Reviewer tier:** pick it when you launch the first review of a target and record it in the tracker; its verify rounds keep the same model. When unsure, take the higher tier.

Design, review triage and short live checks stay with you, the coordinator. So do small fixes quicker to make than to brief; otherwise they go to a Sonnet builder.

The script's defaults follow this table: `claude builder` is Sonnet 5.5 medium (pass `--model claude-opus-5-5` for a heavy builder) and `claude reviewer` is Opus 5.5 high (pass `--effort medium` for a medium target, `--model claude-haiku-5-5` for a simple one). `codex` runs only for a GPT model the user named (`gpt-6.1-sol` by default). Override with `--model` and `--effort`, or `AGENT_RUN_<CLAUDE|CODEX>_<BUILDER|REVIEWER>_MODEL`.

### Pairing

- **The reviewer is a separate run in a fresh context**, never the builder's run and never you. Its model comes from the reviewer tier, not from the author's model.
- Same-reviewer validation goes back to the same reviewer: a new task with the same target and the earlier findings in its prompt.
- A fresh reviewer is a new task with a complete prompt.
- **No fallback model.** A run that cannot start or dies on a provider error (capacity, usage or weekly limit, 429, 503) is not handed to another model or provider. Retry the same model once; if it fails again, stop that slice at a commit, record it in the tracker, and ask the user, or log it in `QUESTIONS.md` when unattended and keep working on slices that do not need it.
- Say which model reviewed and which built whenever it is not the default.

## Prompt rules

- Self-contained: working dir, scope, paths, prohibited actions, evidence to produce, exact output contract.
- Short: point to plans, briefs and lens files by absolute path instead of pasting them; aim under about 1.5K characters. Plain sentences, no squashed shorthand.
- Never paste session history or your own conclusions into a reviewer prompt.
- Builders run unattended with full shell. Their prompt must carry fences (worktree, database, no push unless the lane brief allows it, no real external posts).
- Builders: forbid background commands (`&`, `run_in_background`); the run ends when the agent stops replying and background results are lost. A command too long for one tool call is split by file, shard or filter, never backgrounded.
