# Docs templates

Fill from the code; drop sections that do not apply instead of writing "N/A".

## docs/README.md

```markdown
# <Project> docs

<One paragraph: what the system is and who uses it.>

| Doc | Holds | Read it when |
| --- | --- | --- |
| [architecture.md](architecture.md) | Components, connections, infra, main flows | Starting on the project; touching more than one component |
| [repo-structure.md](repo-structure.md) | Layout, conventions, checks, setup, release | Adding files, running checks, releasing |
| [glossary.md](glossary.md) | Terms, enums, abbreviations | A word or status is unclear |
| [decisions/](decisions/README.md) | Why things are the way they are (ADRs) | Before changing something that looks odd |
| [design/](design/) | Detailed design per component | Changing that component |
| [plans/](plans/) | Build plans in progress (not documentation) | Building |

## Design docs
- [01-<component>.md](design/01-<component>.md) — <one line>
```

## docs/AGENTS.md

```markdown
# Working on docs/

- Docs describe the system as built. Update them in the same change that alters the behavior.
- What to update: new or removed component, store, service or main flow → architecture.md. Changed interfaces, data, flows or invariants of a component → its design/NN file (new component → next NN). New folder, command, check, setup step or release change → repo-structure.md. New term or enum → glossary.md. A decision with alternatives → a new ADR in decisions/.
- Link code paths; never paste code, schemas or enum values. The code is the source of truth for exact shapes.
- Caps: README 60 lines, architecture 300, repo-structure 400, design files 400, ADRs 40. Split above a cap.
- ADRs are never rewritten once accepted; supersede them with a new one.
- plans/ is working state, not documentation; finished plans move to plans/archive/.
```

## docs/architecture.md

```markdown
# Architecture

## Overview
<What the system does, its main parts and how a request moves through them, in 2–3 short paragraphs.>

## Components
| Component | Responsibility | Tech | Code | Design |
| --- | --- | --- | --- | --- |

## Connections
<Diagram (mermaid flowchart) or a table: from → to, protocol, sync/async, what flows.>

## Data
| Store | Holds | Owner component | Notes (retention, backups) |
| --- | --- | --- | --- |

## Infrastructure
Environments, hosting, deploy targets, external services and their limits, secrets handling (where, not values).

## Main flows
### <Flow name>
1. <step: component → component, what happens>

## Cross-cutting
Auth, permissions, observability, configuration, error handling: one or two lines each, linking design docs.
```

## docs/repo-structure.md

```markdown
# Repo structure

## Layout
<tree, depth 2–3, one line per entry on its purpose>

## Where things go
| To add | Put it in | Follow |
| --- | --- | --- |
| an API endpoint | `src/routes/…` | `src/routes/orders.ts` |

## Conventions
Naming, module boundaries, imports, error handling, tests (where, how named), branches and commit messages.

## Checks
The exact commands that must pass before a change is done; agents run these.
- `<lint command>`
- `<typecheck command>`
- `<test command>` (+ `<integration command>` when <condition>)

## Setup and run
Prerequisites, install, env vars (names only), how to run locally, ports.

## Release and versioning
Version scheme and tag format (`vMAJOR.MINOR.PATCH`), changelog, how a release is cut and deployed, rollback.

## Runbooks
### <Task, e.g. rotate a key / replay a job / restore a backup>
1. <step>
```

## docs/glossary.md

```markdown
# Glossary

## Terms
| Term | Meaning | In code |
| --- | --- | --- |
| Render job | One frame range submitted by a user | `internal/domain/job.go` |

## Enums
| Enum | Values (meaning) | Defined in |
| --- | --- | --- |
| JobStatus | queued (waiting for an agent), running, done, failed | `internal/domain/job.go:12` |

## Abbreviations
| Short | Stands for |
| --- | --- |
```

## docs/decisions/README.md

```markdown
# Decisions

ADRs, newest last. Read this index; open an ADR when its area matches your work.

| No | Decision | Status | Date | Area |
| --- | --- | --- | --- | --- |
| [0001](0001-use-d1-for-state.md) | Use D1 for app state | accepted | 2026-03-02 | data |
```

## docs/decisions/NNNN-<title>.md

```markdown
# NNNN. <Decision in a few words>

- **Status:** proposed | accepted | superseded by NNNN | deprecated
- **Date:** YYYY-MM-DD
- **Area:** <data | auth | api | infra | ui | …>
- **Supersedes:** <NNNN or none>

## Context
The forces at play: the problem, constraints, what was true at the time. 3–8 lines.

## Decision
What we do, stated plainly. 1–5 lines.

## Consequences
What gets easier, what gets harder, what we must now keep true.

## Alternatives
- <Option> — rejected because <one line>.
```

## docs/design/NN-<component>.md

```markdown
# <Component>

**Code:** `path/` · **Owner of:** <data or behavior it is the source of truth for> · **ADRs:** 0003, 0007

## Purpose
What it does and what it deliberately does not do.

## Interfaces
APIs, events, commands it exposes and consumes, with code links. Contracts that callers rely on.

## Data
Entities, states and transitions (a small state table or mermaid stateDiagram), persistence.

## Flows
Main paths step by step, including the failure path.

## Invariants
Rules that must always hold, and why.

## Failure modes
What breaks, how it shows, how it recovers (retries, idempotency, timeouts).

## Operations
Config, limits, metrics and logs worth knowing.
```
