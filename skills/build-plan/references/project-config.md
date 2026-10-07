# Project config: `.agents/build.md`

One short file per repo. Every section is optional: when one is missing, `build-plan` falls back to `AGENTS.md`/`CLAUDE.md` and the discovery in [live-check.md](live-check.md). Keep repo-specific knowledge here, never in the shared skills.

```markdown
# Build config

## Roles
- builder: claude opus medium
- reviewer: codex gpt-6.1-sol high
- max parallel builders: 3

## Paths
- scratch: .scratch/            # git-ignored
- worktrees: ../<repo>-worktrees/<lane>

## Gates
- format: pnpm format
- lint: pnpm lint
- typecheck: pnpm check
- full (large changes): pnpm verify
- single test: node --import tsx --test <file>

## Fences for builders
- test database: <url or "create one per worktree with …">
- never: run migrations on the dev database, touch tmux session main, post to real Slack

## Live check
- start: skill `dev-lane` | `pnpm dev` | none
- entry: https://<host>:<port> | ./bin/tool | http://127.0.0.1:8080
- drive: browser | curl | cli | playwright
- suite: pnpm e2e | none
- accounts: test@example.local (password in .env.example)
- known traps: <one line each>

## Review calibration
- Low-volume internal app: no machinery a realistic failure does not need.
```

Rules:

- Write commands exactly as they run from the repo root.
- No secrets. Point to where a test credential lives.
- `start` may name a project skill; `build-plan` invokes it instead of copying its steps.
