# Reviewer Packet

Use this template for the initial reviewer and any fresh reviewer. Include only task-local context; do not fork the full session history.

```text
Review target: <path, diff, task, plan, or design>

Acceptance criteria:
- <criterion>

Review lens:
- <skill or requested standard>

Target and reference files:
- <path>

Behavior or decisions to preserve:
- <item>

Verification evidence:
- <command or diagnostic>: <result>

Known unrelated dirt or failures:
- <item or none>

Earlier findings, fixes, and reviewer replacements:
- <item or none>

Use the requested review lens. Review manually. Do not edit files. Do not spawn subagents.
Return prioritized findings with file and line references where possible and propose a concrete fix for each finding.
End with exactly one verdict: APPROVED or CHANGES REQUIRED.
```

For finding validation, append:

```text
Validate whether each finding you originally raised is resolved. Use the same review lens and inspect the new evidence. Do not broaden scope unless a fix created a new blocker.
```

For a fresh reviewer on a risky target or a final whole-diff review, append:

```text
Review fresh. This loop can close only if you find no blocking findings on this first pass. Earlier findings are context, not proof that the current target is correct.
```
