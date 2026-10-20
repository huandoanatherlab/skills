# Skills

Plan, build, review and debug skills for T3 Code. They load only in T3: one Claude Code plugin (`ath`) that T3's Claude provider loads with `--plugin-dir`, so Claude Desktop, Cowork and plain `claude` sessions never see them. Every builder, reviewer and helper runs as a T3 sub-agent on a Claude model; a GPT model runs only when the user names one.

## Install

```bash
./install.sh --dry-run
./install.sh
```

`install.sh` removes links an older install left in `~/.claude/skills` and `~/.codex/skills` (backups in `~/.skills-backup/<time>/`), links `bin/agent-run` into `~/.local/bin`, and prints the one T3 setting to make:

Settings → Providers → Claude → Launch arguments: `--plugin-dir <repo>\claude`

New T3 threads, and the sub-agents they launch, then list the skills as `ath:<name>`.

## Layout

```
claude/.claude-plugin/plugin.json   plugin manifest (name: ath)
claude/skills/<name>/SKILL.md       the skills
bin/agent-run                       fallback launcher when T3 cannot run a model
proposals/                          daily retro proposals
```

## Flow

```
writing-specs (optional)
writing-plans ─review(plan)→ one plan ─────→ lane-build (solo, this thread)
                           └ master plan ─→ orchestrate (this thread = master)
                                              ├─ lane thread A: lane-build ─ builder / reviewer sub-agents
                                              ├─ lane thread B: lane-build ─ …
                                              └─ merge, gates, whole-build review(code, delivery), cleanup
```

| Skill | Job |
| --- | --- |
| `writing-plans` | Evidence-grounded plan, or a master plan split into lane plans; plan review; hands off to `lane-build` or `orchestrate` |
| `orchestrate` | Master thread: launches one T3 lane thread per lane plan (own worktree, ports, DB), global run budget, merges and gates, master fix slices, whole-build finish, lane close and cleanup |
| `lane-build` | Coordinator of one plan, as a lane or solo: builder and reviewer sub-agents per slice, live proof, finish, pause, resume, status from `TRACKER.md` |
| `review` | Review loop with triage and same-reviewer approval; lenses: plan, code, delivery |
| `agent-run` | Models by job and how to launch a sub-agent with T3 `delegate_task` |
| `writing-specs` | Lasting product (PRD) and design (TDD) docs in `docs/` |
| `systematic-debugging` | Evidence-driven debugging in Quick, Standard or Deep mode; hands large fixes to `writing-plans` and finished fixes to `review` |

## Models

| Work | Model | Effort |
| --- | --- | --- |
| Lookups, reading or editing docs | `claude-haiku-5-5` | unset, no thinking |
| Code mapping | `claude-sonnet-5-5` | low |
| Builder, small fixes | `claude-sonnet-5-5` | medium |
| Heavy builder (cross-package, tricky logic, Sonnet failed) | `claude-opus-5-5` | medium |
| Reviewer, simple target (docs, config, short plan, small normal-risk diff) | `claude-haiku-5-5` | high, read-only |
| Reviewer, medium target (normal code slice, feature plan) | `claude-opus-5-5` | medium, read-only |
| Reviewer, complex target (risky slice, milestone plan, whole-diff, delivery audit) | `claude-opus-5-5` | high, read-only |
| Lane orchestrator thread (set by `orchestrate`) | `claude-opus-5-5` | medium |

Design, review triage and short live checks stay with the coordinator. The reviewer is always a separate run in a fresh context. There is no fallback model: a run that fails on capacity or a usage limit is retried once on the same model, then waits for the user. The full table is in `agent-run`.

## Launching a run

Every run is a T3 `delegate_task` child: Claude models on the `claudeAgent` instance (option `effort`), GPT models on the `codex` instance (option `reasoningEffort`). The codex instance runs whatever binary T3's provider settings name, which on a gateway machine is the gateway's launcher; provider health comes from `orchestrator_capabilities`.

`bin/agent-run` is the fallback when T3 cannot run a model: it runs Claude or Codex as builder or reviewer, resumable by session. Wrap a CLI for one machine with an executable `~/.config/agent-run/codex` or `~/.config/agent-run/claude`.

## Per project

Each repo may add `.agents/build.md` (roles, gates, fences, ports, how to run the app). See `lane-build/references/project.md`. Without it, `lane-build` reads `AGENTS.md`/`CLAUDE.md`, discovers the rest, and proposes the file.
