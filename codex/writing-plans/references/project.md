# Project config and live checks

## `.agents/build.md`

One short file per repo; every section optional. It holds what the shared skills must not: commands, fences, how to run the app, and lasting build rules the user states. No secrets. Roles here override the `agent-run` defaults, so delete the section rather than leave stale roles.

```markdown
# Build config

## Roles
- builder: claude claude-sonnet-5-5 medium
- reviewer: codex gpt-6.1-sol high

## Scratch
- .scratch/

## Git
- base: develop
- ship: PR to base with evidence | merge to base | commit only
- push: allowed | ask
- migrations: <command per environment>

## Gates
- focused (fix rounds): <typecheck and tests of the changed package>
- full (merge, milestone, finish): pnpm format && pnpm lint && pnpm check && pnpm verify
- single test: node --import tsx --test <file>

## Environment
- stack: <docker compose up -d db | none>; stop: <command>
- recipes: <e.g. MIKRO_ORM_MIGRATIONS_SNAPSHOT=false for db:migrate, PGHOST=127.0.0.1>
- seed logins: <where they live>

## Fences
- test database: <url, or how to create one per worktree>
- never: <migrate the dev database, touch tmux session main, post to real Slack>

## Live check
- start: skill `dev-lane` | `pnpm dev` | none
- entry: https://<host>:<port> | ./bin/tool
- drive: browser | curl | cli | playwright (list a fallback, e.g. `t3-preview, else playwright`, to switch without asking)
- suite: pnpm e2e | none
- accounts: <where test credentials live>

## Review calibration
- <one line, e.g. "Low-volume internal app: no machinery a realistic failure does not need.">
```

`start` may name a project skill; invoke it rather than copying its steps.

## Finding how to run the app

When `Live check` is missing, stop at the first source that answers:

1. A project skill that runs the app (`dev-lane`, `run`, `setup-dev-server`).
2. Repo signals: `dev`/`start`/`e2e` scripts, `playwright.config.*`, `Makefile`, `docker-compose*`, README.
3. By project type: **web** start the dev server and drive a browser; **API** start it and `curl`; **CLI** build and run it in a temp dir; **library** a short example script in `build/`; **desktop or mobile** build and launch the dev build, and drive it only if the host has a tool for it.

Then propose the `Live check` section and write it once the user approves.

## Running a live check

- Write `build/live-plan.md`: one row per behavior from the plan's `story` slices (steps, expected result, slice).
- Read-only rows in parallel, state-changing rows serially. BEFORE and AFTER captures for bug fixes.
- Fix what fails and re-run those rows before the acceptance audit.
- Evidence in `build/evidence/`. Label results from seeded or synthetic data.
- Test accounts and data only; never post to real external services.
- Cannot start or drive the app: mark the rows **not verified** with the exact blocker. The delivery review then returns `DELIVERY INCOMPLETE` unless the user waives it in chat. Never write E2E code the plan did not ask for just to get a pass.
