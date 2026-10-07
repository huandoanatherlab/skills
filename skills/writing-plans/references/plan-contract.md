# Plan Artifact Contract

Use this contract for plans that will be executed by an agent or handed to another engineer.

## Header

```markdown
# [Feature Name] [Plan Type]

**Goal:** [One sentence]

**Architecture:** [Two to four sentences naming ownership, source of truth, and flow]

**Tech Stack:** [Only relevant systems and tools]

**Execution:** `build-plan` | human checkpoint

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
- Execution Handoff

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

Use stable slice IDs so execution reports, reviews, and deviations can refer to the same unit of work.

## Review Status

```markdown
## Review Status

- Lens: `plan-review`
- Reviewer: <family/model>, approved its findings in round <N>
- Fresh pass (risky plans only): `APPROVED` | not required
- Residual unrelated issues: none | list
- Status: approved | stopped-with-open-findings
```

Use `approved` only after the complete `thermal-review-loop` done definition is satisfied.
