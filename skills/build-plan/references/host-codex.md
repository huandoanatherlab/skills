# Host notes: Codex

- **Background runs:** Codex has no exit notification. Launch with `nohup <agent-run …> > <run-dir>/launch.log 2>&1 &`, then poll `agent-run status <build dir>/runs` every few minutes with a single `sleep 120; agent-run status …` call, and do useful work (next slice prompt, diff reading) between polls.
- **Native mode:** use Codex subagents only when they exist in this Codex build; otherwise `inline` with an `agent-run` reviewer.
- **Ledger:** mirror slice states with `update_plan`; `TRACKER.md` stays the source of truth.
- **Default families:** builder `codex`, reviewer `claude`. The roles table in `.agents/build.md` overrides this.
