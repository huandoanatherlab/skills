# Code lens

Review the given diff or files manually. Tests and tools are evidence, not verdicts. With no target given, review the current branch diff. Expand scope only far enough to prove a finding.

1. **Correctness.** Trace each meaningful behavior through success, empty, error, cancel, retry, reload and teardown where they apply. Look for: behavior that misses the request or plan; lost data, stale state, races, partial updates; wrong defaults or fallbacks; contract mismatches between callers; validation after a trust boundary instead of before; unhandled existing variants; unsupported input silently turned into empty output (P2).
2. **Ownership.** Logic lives in its rightful owner. Flag: a competing source of truth; domain logic in a catch-all module; code moved without its ownership; a wrapper or interface with no earned boundary; an obsolete path that should be deleted; types weakened by casts, `any` or loose optionality; lifecycle with no owner.
3. **Simplicity.** Prefer deletion and reuse. Flag real duplication, needless dependencies, sprawling modes, and files growing without a split. Recommend the smallest structural fix.
4. **Verification.** Tests must prove the changed boundary, not just run nearby code: user-visible behavior, failure and migration paths, permission decisions, persistence and reload, deleted architecture, concurrency. Flag copy, prompt-text or DOM-shape assertions.

Output: findings highest severity first (severity, `file:line`, failure scenario, why it matters, smallest fix), then verification you assessed or ran, strengths not to rework, and unrelated dirt. End with `APPROVED` (no P0-P2 open) or `CHANGES REQUIRED`.
