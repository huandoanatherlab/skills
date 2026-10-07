# PRD Standard

## Organization

Keep `docs/prd/README.md` as the index. Prefer one document per feature; extract shared vocabulary, business rules, or NFRs only when reused. Link to original product evidence rather than copying it unnecessarily.

Keep metadata small: stable document ID, title, status, version, and update date. Record owners when known. Use status to describe document maturity, not permission to work; do not invent approval.

## Requirements and Acceptance

- Write singular, observable requirements with a source and testable acceptance criteria. A user request, product decision, or existing source can supply the evidence.
- Use stable IDs for requirements that need tracing; preserve them across edits. Link acceptance criteria directly to their requirement rather than creating extra identifiers without a use.
- Prioritize when it helps scope decisions. Plain language is sufficient. EARS and Given/When/Then are optional formats.
- If using MUST/SHOULD/MAY, reserve MUST for genuine product obligations and avoid turning assumptions into mandatory rules.
- State measurable thresholds only when supported; use observable outcomes otherwise. Keep proposed targets visibly proposed.
- Separate confirmed intent, existing behavior, assumptions, and open questions. Include implementation choices only when they are actual product constraints.
- Non-goals delimit the current feature/version; future authorized requests may change them.

Example:

```markdown
### REQ-ORD-001 — Confirm an order
Source: current task / linked product decision

After a successful order submission, show the order reference.
Acceptance: a successfully created order displays its reference; a rejected
submission displays the reason and does not show a success confirmation.
```

## Review Checklist

Apply to the changed scope:

- Problem, outcome, actors, and scope agree.
- Requirements have clear sources and observable acceptance criteria.
- Relevant business rules, failures, and edge cases are covered.
- Assumptions are labeled; open questions identify their impact and affected work.
- Product intent is not inferred solely from implementation.
- IDs/links resolve and affected TDDs are consistent or remaining updates are identified.
- Metadata/history reflects meaningful changes under the skill's versioning convention.
- No document status, review label, or non-goal creates an implicit approval gate.

Readiness depends on enough product clarity for the affected design work, not a mandatory independent review. A question about one part need not block unrelated parts.
