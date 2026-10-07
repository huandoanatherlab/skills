# Build dir layout and tracker

```
<scratch>/<topic>/build/
  TRACKER.md            handoff header, slice table, timestamped log
  QUESTIONS.md          open questions with your recommendation
  briefs/COMMON.md      builder brief
  briefs/REVIEW.md      review brief
  runs/<slice>/         builder session: prompt.md, meta, turn-N.*, report.md, triage-N.md
  runs/<slice>-review/  reviewer session
  runs/final-review/    whole-diff reviewer
  live-plan.md
  evidence/
  FINAL-REPORT.md
```

`TRACKER.md`:

```markdown
# Build: <topic>

**Plan:** <path>  **Branch:** <branch>  **Base:** <sha>  **Worktree:** <path>
**Now:** <current step and what is running>
**Authority:** <what the user allowed: unattended, merges, design changes>

| Slice | Mode | Builder | Reviewer | State | Commit | Verdict | Live | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S01 | cross | claude opus/medium | codex gpt-6.1-sol/high | complete | abc123 | APPROVED r2 | story ✓ | evidence/s01-*.png |

States: pending, blocked (name the blocker), building, checking, reviewing, fixing, complete.

## Log
- 2026-10-07 14:02 S01 builder started
```

Update **Now** before every long wait, so a fresh session can resume from this file alone.
