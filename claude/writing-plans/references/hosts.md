# Host notes

## Claude Code

- **Launchers:** T3 `delegate_task` when present. Without it, Claude runs (builder, helpers) use the `Agent` tool and the Codex reviewer uses the `agent-run` script (details in the `agent-run` skill).
- **Waiting:** T3 tasks and `Agent` runs notify you when they end. Start the script with the Bash tool's `run_in_background`; it notifies too. Do not poll with sleep loops. For long runs, one fallback wake (`ScheduleWakeup`) no more often than every 20 minutes, cancelled when the run ends.
- **Ledger:** mirror slice states in the todo tracker; `TRACKER.md` stays the source of truth.
- **Handoff:** a fresh T3 thread when in T3, otherwise a fresh session; either resumes from `TRACKER.md`.
- **Defaults:** builder Opus 5.5 medium, reviewer Codex `gpt-6.1-sol` high.
