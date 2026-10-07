# Plan lens

A plan is a set of checkable claims. A review that reads only the document is incomplete: read the files it cites.

1. **Inventory.** Extract every referenced file and owner, current-state claim, decision and invariant, slice and dependency, each slice's live proof level and risk tag, acceptance criterion and proof command, and repo rule that constrains the work. Check that cited paths exist and look for participating files the plan missed.
2. **Current state.** Read every file the plan changes plus the adjacent code needed to confirm ownership and flow. Confirm or refute each claim with `file:line`: source of truth, contract boundaries, error and teardown paths, existing tests, naming.
3. **Primary sources.** For a port, parity claim, migration or spec, read the source itself, not the plan's summary. Compare contracts, enums, guards, failure behavior and permissions exactly.
4. **Simulate the build.** Execute each slice in order using only its checklist. Flag: an acceptance criterion no slice implements; a proof command needing something no slice creates; a slice assuming work another defers; a choice left to the builder that admits materially different results; an implied compatibility or migration policy; a deletion with no proof; a live proof level that cannot prove the done criteria.
5. **Architecture.** Does behavior move to its rightful owner or just relocate? Flag duplicate vocabularies, one-to-one wrappers, new catch-all modules. Do not relitigate decisions the plan already resolved; check they reach the slices.

Output: a short summary (direction, strongest confirmations, whether building can start), then numbered findings with plan `file:line`, supporting code `file:line`, impact and required fix. Advisory notes separate. End with `APPROVED` or `CHANGES REQUIRED`.
