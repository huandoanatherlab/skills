# Model Profiles

Model catalogs change. Update this file, not the skills that use it. Verify a model with a one-line ping before a long run.

## Codex

| Work | Model | Effort |
| --- | --- | --- |
| Mechanical edits, lookups | `gpt-6.1-sol` | low |
| Implementation | `gpt-6.1-sol` | medium |
| Code, plan or architecture review | `gpt-6.1-sol` | high |
| Exceptional hard reasoning | `gpt-6.1-sol` | xhigh, only when justified |

## Claude

| Work | Model | Effort |
| --- | --- | --- |
| Mechanical edits | `sonnet` | low |
| Implementation | `opus` | medium |
| Review | `opus` | high |
| Hard design or plan review | `fable` | high |

## Pairing

- Builder and reviewer come from different families by default: Claude builds, Codex reviews, or the reverse. Different families miss different bugs.
- Same-reviewer validation keeps the same run dir, so the same model and session.
- A fresh reviewer is a new run dir.
- If a family is down, use the other family's strongest model or a native subagent, and say which one you used.
