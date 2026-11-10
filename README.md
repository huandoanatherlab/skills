# Skills

Personal skills for planning, building, reviewing, debugging, documenting and cleaning up code changes. They are plain [Agent Skills](https://agentskills.io) folders, so they work in Claude Code (CLI, T3 Code) and in agents that read `~/.agents/skills`, such as Codex. T3-only extras (thread titles, parallel plan threads, PR watch) switch on when T3's tools are present.

## Install

```bash
./install.sh --dry-run
./install.sh            # --copy where symlinks are unavailable (Windows without Developer Mode)
```

The script:
- links each `skills/ath-*` folder into `~/.claude/skills/` and `~/.agents/skills/`;
- links the three roles into `~/.claude/agents/` as `ath-builder`, `ath-reviewer` and `ath-scout`;
- removes links that older installs left behind.

Edits in this repo are live, except where the script had to copy; then re-run it after each change.

After installing:
- If T3 still has `--plugin-dir …/claude` under Launch arguments, remove it.
- Set `"worktree": { "baseRef": "head" }` in `~/.claude/settings.json`. Parallel builders need it.

## How work flows

```
request ─ small? ── just do it, run checks, report
        └ ath-plan ── branch feat/<topic> (T3: this thread moves into its worktree)
                      docs/plans/<topic>/plan.md + plan.progress.json, reviewed, "chốt"
          ath-execute (same session)
            per slice: builder → coordinator re-runs checks → reviewer → fix rounds (≤2) → done
            finish: full checks → final review → docs sync → cleanup → archive plan → one PR
            PR merged → cleanup of the worktree and branch
```

- **One session per plan.** The session you plan in is the one that builds, so it never hands off for context. The progress file holds the state, and auto-compaction keeps the session going.
- **Roles, not ad-hoc prompts.** `ath-builder`, `ath-reviewer` and `ath-scout` each have their own instructions, model and tools.
  - In Claude Code they are native agents, and fix and verify rounds continue the same agent with `SendMessage`.
  - Elsewhere a sub-agent is told to read the role file. See `skills/ath-execute/roles/README.md`.
- **Big topics:** `00-index.md` plus several plan files, all merged into `feat/<topic>`, with one PR.
  - In T3, each plan runs in its own thread and worktree, in parallel.
  - Elsewhere they run one after another.

## Layout

```
skills/ath-plan/       SKILL.md, references/plan-format.md
skills/ath-execute/    SKILL.md, references/home.md, roles/{builder,reviewer,scout}.md, scripts/status
skills/ath-review/     SKILL.md
skills/ath-debug/      SKILL.md, references/
skills/ath-docs/       SKILL.md, references/templates.md
skills/ath-cleanup/    SKILL.md, scripts/cleanup
```

| Skill | Job |
| --- | --- |
| `ath-plan` | Decides whether a plan is needed; sets up the main branch (and worktree in T3); writes a grounded plan with checkable acceptance; runs the plan review; waits for go |
| `ath-execute` | Slice loop with circuit breakers, final review, docs sync, cleanup, PR. Also status, pause and resume, and acting as home for several plans |
| `ath-review` | Ad-hoc review of a plan, diff or PR by the reviewer role, with triage and an optional fix loop |
| `ath-debug` | Evidence-first debugging: failing test first, a hypothesis log, breakers, production kept read-only |
| `ath-docs` | Keeps `docs/` in one standard shape: init, migrate an old project, sync after a build, ADRs |
| `ath-cleanup` | Exact, verified removal of worktrees, branches, processes, containers, threads, schedules and debug lines |

## Models (Claude Code)

| Role | Model | Effort | Tools |
| --- | --- | --- | --- |
| `ath-builder` | `claude-sonnet-5-5` | medium | all, `maxTurns` 150 |
| `ath-reviewer` | `claude-opus-5-5` | medium | read-only (no Edit, Write, Agent) |
| `ath-scout` | `claude-haiku-5-5` | default | Read, Grep, Glob, Bash |
| coordinator | the session's own model | | |

Other agents use whatever models their harness picks for sub-agents.

## Per project

There is no per-repo config file. The skills read the repo's `AGENTS.md`/`CLAUDE.md` and its `docs/`.
- The checks come from `docs/repo-structure.md` → `## Checks`, or else from CI and the package scripts.
- Lasting rules go into `AGENTS.md`.
