# Host notes

## Claude Code

- **Launchers:** T3 `delegate_task` when present. Without it, every run (builder, reviewer, helpers) uses the `Agent` tool, or the `agent-run` script when the tool cannot set the model or effort (details in the `agent-run` skill).
- **Waiting:** T3 tasks and `Agent` runs notify you when they end. Start the script with the Bash tool's `run_in_background`; it notifies too. Do not poll with sleep loops. For long runs, one fallback wake (`ScheduleWakeup`) no more often than every 20 minutes, cancelled when the run ends.
- **Ledger:** mirror slice states in the todo tracker; `TRACKER.md` stays the source of truth. Never keep build state in memory files.
- **Handoff:** pause first (`writing-plans`); then a fresh T3 thread when in T3, otherwise a fresh session; either resumes from `TRACKER.md`.
- **Defaults:** builder Sonnet 5.5 medium (Opus 5.5 medium for a heavy slice), reviewer by tier: Haiku 5.5 high, Opus 5.5 medium, or Opus 5.5 high for a complex target.
