# Master templates

Copy into `<scratch>/<topic>/build/` and fill every `<…>`. Point to the master plan and project rules instead of copying them.

## LANE-BRIEF.md (read by every lane)

```markdown
# Lane brief: <topic>

You are a lane orchestrator of `<master plan path>`. Run `lane-build` as a **lane** on the lane plan your launch message names. Go is given; do not re-plan.

- **Master:** thread `<master threadId>`. Report with `t3_thread_send` (`mode: queue`): `MERGE-READY <slice> at <sha>`, `BLOCKED <slice>: <reason>`, `DONE <lane> at <sha>, report <path>`. Nothing else needs a message.
- **Worktree:** the one T3 bound to this thread. Do not create other worktrees except through `delegate_task` `isolation: worktree`. Never write in another lane's worktree or in the main checkout.
- **State:** `<scratch>/<topic>/build/<NN-area>/` (TRACKER with `**Role:** lane`, QUESTIONS, briefs, runs, evidence, FINAL-REPORT). Never edit the master's files.
- **Git:** commit per slice and fix round, push your branch after every commit; builders push too. Never merge into `<integration>`, never push to `<base>`, no `--force`, no rebase of pushed commits. Merge `<integration>` in only when the master asks or a dependency merged.
- **Hot files:** <file or number space — owning lane or reserved range>. Touch only what your lane owns; ask the master for anything else.
- **Resources:** only those in your launch message (ports, DB, build dir, container prefix). List everything you create under Resources and remove only those.
- **Budget:** your share of builders and runs is in your launch message; the master may change it by message.
- **Liveness:** keep `Now:` current with a timestamp; every long command runs with a timeout; cancel a run idle 20 minutes. The master's health check pings you if a wake-up is lost; you keep no schedule.
- **Gates:** focused gates per slice; the master runs the full gates at merge: `<full gate commands>`.
- **Fences:** <databases, services and accounts you must not touch; no deploy; no real external posts>.
- **Done:** every lane slice complete, whole-lane review approved, lane FINAL-REPORT written, processes stopped, `MERGE-READY <last slice> at <final sha>`, then `DONE`.
```

## Lane launch message

```text
You are lane <letter> (<NN-area>) of <topic>. Load lane-build and read <abs path>/LANE-BRIEF.md first.
Lane plan: <abs path>. State dir: <abs path>/<NN-area>/. Master thread: <threadId>.
Ports: dev <p>, E2E <p>. Test DB: <name>. Build dir: <path>. Container prefix: <prefix>.
Budget: <n> builders, <m> runs at once.
Waits for: <slice or none>. Feeds: <lane/slice that waits for you, or none> — post MERGE-READY for those.
```

## TRACKER.md (master)

```markdown
# Master build: <topic>

**Role:** master  **Thread:** <this threadId>
**Master plan:** <path>  **Integration:** <branch>@<sha>  **Base:** <branch>
**Now:** <current step, waiting merges, next action> (<time>)
**Progress:** <lanes closed>/<lanes> lanes, <slices merged>/<slices> slices
**Budget:** <builders>/3 builders, <runs>/6 runs in use
**Authority:** <what the user allowed>

| Lane | Plan | Thread | Worktree | Branch | Ports | DB | State | Share | Last Now |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

States: waiting, preparing, building, merge-ready, paused, done, closed.

## Merges
| Time | Lane | Slice | Sha | Gates | Pushed |
| --- | --- | --- | --- | --- | --- |

## Master fix slices
| Slice | Builder | Reviewer | State | Commits | Verdict |
| --- | --- | --- | --- | --- | --- |

## Resources
- <health check schedule id, master worktrees of fix slices, master-only ports, gate processes> — <removed?>

## Log
- <time> <event>
```

Update **Now**, **Budget** and the Lanes table before every wait so a successor master can resume from this file alone.
