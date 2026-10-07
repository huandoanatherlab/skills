# Live check

The plan decides **what** must be proven: each slice has a live proof level. The project config only says **how** to run the app. This file covers the part between.

## Levels

| Level | Use for | Evidence |
| --- | --- | --- |
| `none` | Pure library or internal logic with no runtime behavior | The slice's focused tests |
| `smoke` | Internal change; the app must still run | App starts, health check passes, one main flow works |
| `story` | User-visible behavior | One test-plan row per behavior, driven like a real user, with screenshot or output |
| `suite` | The project's E2E suite covers the area | The suite command passes for the relevant specs |

The rows of a `story` check come from the plan's acceptance criteria, not from the project config.

## Find how to run the app

Stop at the first source that answers:

1. `.agents/build.md` → `Live check`.
2. A project skill for running the app (for example `dev-lane`, `run`, `setup-dev-server`).
3. Repo signals: `dev`/`start`/`e2e` scripts in `package.json`, `playwright.config.*`, `Makefile`, `docker-compose*`, `Procfile`, README "Getting started".
4. Recipe by project type:
   - **Web app:** start the dev server, drive it with the browser tool the host has (in-app browser, Playwright script, agent-browser).
   - **HTTP API:** start the server, call endpoints with `curl`, check status and body.
   - **CLI:** build, run the binary against a temp dir, check output and exit code.
   - **Library:** write a short example script in the build dir that uses the public API.
   - **Desktop or mobile:** build and launch the dev build; drive it only if the host has a tool for it.

When you discovered the method yourself, propose the `Live check` section to the user and write it to `.agents/build.md` once approved, so the next run skips discovery.

## Run it

- Write `<build dir>/live-plan.md`: one row per behavior with steps, expected result, and the slice it proves.
- Run read-only rows in parallel and state-changing rows serially.
- Save evidence under `<build dir>/evidence/` (screenshots, command output). Capture BEFORE and AFTER for bug fixes.
- Fix what fails and re-run those rows.
- Use only test accounts and test data. Never post to real external services.
- Label any result that came from seeded or synthetic data.

## When it cannot run

If a slice needs `smoke` or `story` and the app cannot be started or driven (missing infra, credentials, a tool the host lacks):

- Mark those rows **not verified** with the exact blocker.
- `verify-plan-delivery` returns `DELIVERY INCOMPLETE` for them unless the user waives the live check in chat; record the waiver in `FINAL-REPORT.md`.
- Never write E2E test code the plan did not ask for just to get a pass.
