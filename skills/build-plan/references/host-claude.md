# Host notes: Claude Code

- **Background runs:** start `agent-run` with the Bash tool's `run_in_background`; you are notified when it exits. Do not poll it with sleep loops.
- **Fallback wake:** for long runs, schedule one wake no more often than every 20 minutes (`ScheduleWakeup` or `/loop`) and cancel it when the run ends.
- **Native mode:** a builder or reviewer is a named Agent call with a self-contained prompt, never a fork of this session. Return findings or fixes with SendMessage to the same named agent. The Agent tool cannot set effort; use `agent-run start … claude …` when effort matters.
- **Ledger:** mirror slice states in the todo tracker for the user; `TRACKER.md` stays the source of truth.
- **Default families:** builder `claude`, reviewer `codex`.
