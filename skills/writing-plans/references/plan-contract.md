# Plan Artifact Contract

Use this contract for plans that will be executed by an agent or handed to another engineer.

## Header

```markdown
# [Feature Name] [Plan Type]

**Goal:** [One sentence]

**Architecture:** [Two to four sentences naming ownership, source of truth, and flow]

**Tech Stack:** [Only relevant systems and tools]

---
```

## Sections

Include only applicable sections, but never omit information an implementer would otherwise have to decide:

- Current Shape / Baseline
- Target Shape
- Decisions and Invariants
- Non-Goals
- Ownership / File Map
- Source Inventory
- Implementation Slices
- Final Verification
- Review Status
- Risks / Open Questions

## Slice

```markdown
### S01: Slice name

**Depends on:** none | S00

**Live proof:** none | smoke | story: <behaviors> | suite: <specs>    **Risk:** normal | risky

**Scope:** One short paragraph describing the independently reviewable outcome.

**Files:**

- Create: `path`
- Modify: `path`
- Test: `path`

**Boundary Shape:** Key interfaces, functions, data flow, or ownership boundaries when needed.

**Checklist:**

- [ ] Five to ten meaningful implementation decisions or proof items.

**Verification:**

- `focused command` — expected evidence

**Done when:**

- Observable behavior, test evidence, diagnostic result, deletion proof, or architecture proof.
```

Use stable slice IDs so build reports, reviews, and deviations can refer to the same unit of work.

### Live proof levels

Decided in the plan so review can challenge it. Name behaviors, not tooling; how to run the app lives in `.agents/build.md`.

| Level | Use for | Evidence |
| --- | --- | --- |
| `none` | Pure library or internal logic | The slice's focused tests |
| `smoke` | Internal change; the app must still run | App starts, health check passes, one main flow works |
| `story` | User-visible behavior | One row per named behavior, driven like a real user, with screenshot or output |
| `suite` | The project's E2E suite covers it | The named specs pass |

### Risk

`risky` when the slice touches migrations, persistence, permissions, security or a public contract; otherwise `normal`. A risky slice needs a fresh reviewer's first-pass approval (see `review`).

## Review Status

```markdown
## Review Status

- Lens: `review` plan lens
- Reviewer: <family/model>, approved its findings in round <N>
- Fresh pass (risky plans only): `APPROVED` | not required
- Residual unrelated issues: none | list
- Status: approved | stopped-with-open-findings
```

Use `approved` only after the `review` loop's done definition is satisfied.
