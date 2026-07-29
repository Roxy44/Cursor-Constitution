# Project memory

Working memory for the team and the agent. These files are **not** auto-loaded into
context — the agent opens them per constitution **M-2** / **M-4** or when asked. Volume
here does not cost tokens every session.

Write entries in the project's **communication language** (see `project/stack.mdc`).

| File | Purpose |
| --- | --- |
| `tasks.md` | Current and deferred tasks, follow-ups after temporary decisions |
| `knowledge-base.md` | Facts you cannot infer from code: agreements, external systems, constraints |
| `ideas.md` | Ideas not yet decided |
| `lessons/` | Failure write-ups: symptom, cause, takeaway (format in `retrospective.mdc`) |

## Rules

1. Short and factual. This is not a diary — someone will read every entry later.
2. Delete or mark stale notes. Wrong memory is worse than no memory.
3. The same takeaway a third time → promote to a project rule under
   `.cursor/rules/project/`, do not write a fourth note.
4. No secrets, tokens, or personal data here.
