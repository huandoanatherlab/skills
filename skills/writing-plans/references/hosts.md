# Host notes

## Claude Code

- **Background runs:** start `agent-run` with the Bash tool's `run_in_background`; you are notified when it exits. Do not poll with sleep loops. For long runs, one fallback wake (`ScheduleWakeup`) no more often than every 20 minutes, cancelled when the run ends.
- **Native mode:** a named Agent call with a self-contained prompt, never a fork. Return findings or fixes with SendMessage to the same named agent. The Agent tool cannot set effort; use `agent-run … claude …` when effort matters.
- **Ledger:** mirror slice states in the todo tracker; `TRACKER.md` stays the source of truth.
- **Defaults:** builder `claude` (Sonnet 5.5), reviewer `claude` (Opus 5.5).

## Codex

- **Background runs:** no exit notification. Launch with `nohup agent-run … > <run-dir>/launch.log 2>&1 &`, then poll with a single `sleep 120; agent-run status <build>/runs` call, doing useful work (next prompt, reading diffs) between polls.
- **Native mode:** Codex subagents only when this Codex build has them; otherwise `inline` with an `agent-run` reviewer.
- **Ledger:** mirror slice states with `update_plan`; `TRACKER.md` stays the source of truth.
- **Defaults:** builder `claude` (Sonnet 5.5), reviewer `claude` (Opus 5.5), both through `agent-run`.
