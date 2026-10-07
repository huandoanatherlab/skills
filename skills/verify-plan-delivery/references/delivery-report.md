# Delivery Report Template

```markdown
## Delivery Verification

**Plan:** `<path>`
**Plan review:** approved | waived by user | stopped-with-open-findings
**Final changed files:** `<source>`

### Slice Evidence

| Slice | Implementation | Focused verification | Code review | Live proof | Status |
| --- | --- | --- | --- | --- | --- |
| S01 | `<evidence>` | `<command and result>` | `<verdict>` | `<level: evidence path / not verified: blocker / waived>` | complete / incomplete |

### Acceptance Criteria

| Criterion | Evidence | Status |
| --- | --- | --- |
| `<criterion>` | `<behavior, test, diagnostic, or file state>` | proven / missing |

### Final Gates

- `<command>` — pass / fail: `<evidence>`

### Architecture And Deletion Proof

- Source of truth: `<evidence>`
- Ownership and lifecycle: `<evidence>`
- Removed paths or concepts: `<grep, file, caller, or line-count evidence>`

### Deviations

- accepted: `<item or none>`
- benign: `<item or none>`
- blocking: `<item or none>`

### Residual Dirt Or Failures

- `<item or none>`

DELIVERY COMPLETE | DELIVERY INCOMPLETE
```

Replace the final line with exactly one verdict.
