# Plan format

Written for an agent that has not seen the conversation. It should be short enough to scan and exact enough to build without making product or architecture decisions. Aim for under 300 lines per plan file. Link to code and docs by path instead of repeating them.

## plan.md (or NN-area.md)

```markdown
# <Title>

**Main branch:** feat/<topic> from <base>@<sha>   **Plan branch:** same | feat/<topic>--NN-<area>
**Status:** draft | approved (<date>) | done

## Context
Why this change, what problem it solves, the outcome in 2–4 sentences.

## Scope
In: … Out (only what someone would reasonably expect to be in): …

## Approach
The chosen design only, no alternatives. Ownership and source of truth, the flow,
key interfaces. Existing functions and patterns to reuse, with paths.

## Decisions
- D1: <decision> — <why>. (Becomes an ADR at finish.)

## Slices

| ID | Goal | Group | Depends | Risk |
| --- | --- | --- | --- | --- |
| S01 | … | A | – | normal |
| S02 | … | A | – | normal |
| S03 | … | B | S01 | risky |

### S01 — <name>
**Files:** `path` (create/modify/delete) …
**Notes:** only what the builder cannot infer: boundary shapes, invariants, gotchas.
**Acceptance:**
- S01.1 `bun test src/billing/rate.test.ts` → exit 0
- S01.2 `rg -n "legacyRate" src` → no matches (old path deleted)
- S01.3 live: POST /api/rates twice in 1s → second returns 429 (evidence: curl output)

## Verification
End-to-end checks for the whole plan, run at finish (commands, or live flows with evidence).

## Done when
All slices done, the full checks pass, the final review approves, docs synced.
```

## 00-index.md (several plans)

```markdown
# <Topic>

**Main branch:** feat/<topic> from <base>@<sha>   **Status:** draft | approved | done
## Context  (as above)
## Plans
| Plan | Goal | Depends | Can run with |
| --- | --- | --- | --- |
| 01-api.md | … | – | 02 |
| 02-web.md | … | – | 01 |
| 03-reports.md | … | 01 | – |
## Shared files
Files or number spaces more than one plan touches (migrations, route index, generated code), each with one owning plan.
## Verification / Done when  (for the whole topic, after all plans merge)
```

## Slice rules

- **Size:** one builder session, about 90 minutes or less, about 10 files or fewer. Bigger: split it.
- **Group:** slices in the same group run in parallel, so they must not touch the same files, and must not depend on each other. Groups run in order (A, then B…). With no parallelism, give each slice its own group.
- **Risk:** `risky` when the slice touches migrations, persistence, permissions, security, money or a public contract. It tells the reviewer where to look harder.

## Acceptance checks

The slice is done when every check passes when the **coordinator re-runs it**, not when the builder says so.

- **Command check:** an exact command run from the worktree root, and the expected result (`exit 0`, `prints …`, `no matches`). Prefer the narrowest test or command that proves the goal.
- **Live check:** a named user-visible behavior and the evidence to save (screenshot, curl output, log line) under `.tmp/evidence/`. Use only when a command cannot prove it. A UI change needs one: the touched page opens, including with empty data.
- **Deletion check:** an `rg`/`test ! -e` command proving the old path is gone.
- Never: "works", "is clean", "tests pass" without naming them, or a check that cannot fail.

## <plan>.progress.json

The machine-readable state of one plan, committed next to it. Only the coordinator writes it. The builder never touches it.

```json
{
  "plan": "docs/plans/<topic>/plan.md",
  "branch": "feat/<topic>",
  "base": "<sha the plan branch started from>",
  "state": "draft",
  "home": null,
  "slices": [
    {
      "id": "S01", "group": "A", "depends": [], "risk": "normal",
      "status": "pending", "rounds": 0, "commits": [], "note": "",
      "checks": [
        { "id": "S01.1", "run": "bun test src/billing/rate.test.ts", "expect": "exit 0", "pass": false },
        { "id": "S01.3", "live": "second POST in 1s returns 429", "evidence": null, "pass": false }
      ]
    }
  ],
  "resources": [],
  "questions": [],
  "log": []
}
```

- `state`: `draft`, `approved`, `building`, `paused`, `blocked`, `done`.
- `fullChecks`: the repo's full check commands, filled by `ath-execute` at start (`["bun run lint", "bun test"]`).
- slice `status`: `pending`, `building`, `reviewing`, `blocked`, `done`. `rounds` counts fix rounds.
- `base`: set when the build starts (`ath-execute` Start), not at planning time, so a plan that starts after others merged diffs only its own work.
- `resources`: everything the run creates that cleanup must remove: `{ "kind": "worktree|branch|process|container|db|dir|schedule|thread", "id": "<exact path, name or id>", "by": "S02", "removed": false }`.
- `questions`: `{ "q": "…", "default": "what I did meanwhile", "blocking": false, "answered": false }`.
- `log`: one short line per event, newest last: `"2026-11-10T15:00Z S01 done, 1 round"`.
- `home` (plan files under an index): the thread id of the home thread to report to.
- Commit the file on every state change (`chore(plan): …`), so a resume, another machine or a compacted thread sees the truth.

### 00-index.progress.json

The home's state for several plans, same rules:

```json
{
  "index": "docs/plans/<topic>/00-index.md",
  "branch": "feat/<topic>", "base": "<sha>", "state": "draft",
  "fullChecks": [],
  "plans": [
    { "file": "01-api.md", "depends": [], "branch": null, "worktree": null, "thread": null,
      "state": "pending", "merged": null, "mergeAttempts": 0 }
  ],
  "resources": [], "questions": [], "log": []
}
```

Plan `state`: `pending`, `running`, `done` (reported DONE, not merged yet), `merged`, `blocked`.
