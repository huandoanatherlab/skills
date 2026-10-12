# Host notes

## Codex

- **Launchers:** T3 `delegate_task` when present. Without it, the Codex reviewer uses Codex's subagent tool when this build has one, and the Claude builder uses the `agent-run` script (details in the `agent-run` skill).
- **Waiting:** T3 tasks wake the thread when they end. The script gives no exit notification: launch with `nohup agent-run … > <run-dir>/launch.log 2>&1 &`, do useful work (next prompt, reading diffs), then block with one `agent-run wait <build>/runs --timeout 30` call instead of sleep loops.
- **Ledger:** mirror slice states with `update_plan`; `TRACKER.md` stays the source of truth. Never keep build state in memory files.
- **Handoff:** pause first (`writing-plans`); then a fresh T3 thread when in T3, otherwise a fresh session; either resumes from `TRACKER.md`.
- **Defaults:** builder Opus 5.5 medium, reviewer Codex `gpt-6.1-sol` high. You write GPT code here, so your own plans and inline slices go to an Opus 5.5 reviewer.
