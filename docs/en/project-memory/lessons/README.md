# Failure write-ups

One file per write-up, named `YYYY-MM-DD-short-slug.md`. Format and when-to-write rules:
`.cursor/rules/retrospective.mdc`.

Write in the project's communication language.

Template:

```markdown
# Short title

- **Symptom:** what was observed.
- **Cause:** the real root cause, not the first suspect.
- **Fix:** what changed, with file paths.
- **Rule of thumb:** one sentence a future agent needs.
- **Scope:** where this applies (module, layer, whole repo).
```

The same takeaway a third time → promote to a project rule under
`.cursor/rules/project/`, do not write a fourth note.
