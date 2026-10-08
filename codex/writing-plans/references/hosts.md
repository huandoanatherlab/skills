# Host notes

## Codex

- **Background runs:** no exit notification. Launch with `nohup agent-run … > <run-dir>/launch.log 2>&1 &`, then poll with a single `sleep 120; agent-run status <build>/runs` call, doing useful work (next prompt, reading diffs) between polls.
- **Native mode:** Codex subagents only when this Codex build has them; otherwise `inline` with an `agent-run` reviewer.
- **Ledger:** mirror slice states with `update_plan`; `TRACKER.md` stays the source of truth.
- **Defaults:** builder `codex` (`gpt-6.1-sol` medium), reviewer `codex` (`gpt-6-astra` medium), both through `agent-run`.
