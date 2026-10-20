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

**Size:** one builder run of about 90 minutes or less. Split a slice that spans several modules on both backend and frontend. For a port, write the rules from the source into the slice before building, so the builder does not fit them to fixtures. Long-running workers log their progress.

### Live proof levels

Decided in the plan so review can challenge it. Name behaviors, not tooling; how to run the app lives in `.agents/build.md`.

| Level | Use for | Evidence |
| --- | --- | --- |
| `none` | Pure library or internal logic | The slice's focused tests |
| `smoke` | Internal change; the app must still run | App starts, health check passes, one main flow works |
| `story` | User-visible behavior | One row per named behavior, driven like a real user, with screenshot or output |
| `suite` | The project's E2E suite covers it | The named specs pass |

A slice that changes UI needs at least `story`: every touched page opens, including with empty and null data. A slice that calls an external API needs a `story` against one real sample, or it is marked not verified.

### Risk

`risky` when the slice touches migrations, persistence, permissions, security or a public contract; otherwise `normal`. A risky slice needs a fresh reviewer's first-pass approval (see `review`). A plan is risky when any of its slices is.

## Master plan

`00-master.md` uses the same header, then these sections; each lane plan is a normal plan under this contract.

- **Lanes:** one row per lane: ID prefix, lane plan file, goal, slices, depends on (lane or slice), feeds (who waits for it), branch `feat/<area>`.
- **Integration:** the integration branch the lanes start from and merge into (for example `develop` or `feat/<topic>`), and what moves it to the base at the end.
- **Merge points:** which lane slices must merge before another lane can start or continue, in order.
- **Hot files:** every file or number space more than one lane touches (migration numbers, route trees, nav and index files, generated code, version rows in docs), each with one owning lane or a reserved range per lane (migrations `0100-0199` for lane A).
- **Resources:** per lane: dev and E2E ports, test database, build-output dir, container or image prefix. The master gets its own ports for merge gates. No two lanes share any of them.
- **Finish:** the whole-build acceptance criteria the delivery audit checks.

## Review Status

```markdown
## Review Status

- Lens: `review` plan lens
- Reviewer: <model and effort>, approved its findings in round <N>
- Fresh pass (risky plans only): `APPROVED` | not required
- Residual unrelated issues: none | list
- Status: approved | stopped-with-open-findings
```

Use `approved` only after the `review` loop's done definition is satisfied.
