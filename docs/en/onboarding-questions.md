# Onboarding questionnaire

The same questions the agent asks via `onboarding.mdc`, written for a human. Use this if
you want to fill `project/stack.mdc` by hand.

Works in two situations:

| Situation | Where the stack comes from |
| --- | --- |
| Code / manifests already exist | Agent reads the repo and only confirms |
| Empty or nearly empty repo | Options from [`stack-catalog.md`](stack-catalog.md) |

## Questions

1. **Language.** What language should the agent use when talking to you and when writing
   notes in `project-memory`? Also sets docs locale (`docs/en` or `docs/ru`). This does
   **not** ban other languages in source UI strings unless you say so in Q7.
2. **Project type.** Frontend, backend, fullstack, library, CLI, mobile?
3. **Stack.**
   - Existing project: what the manifest already shows — what to correct?
   - Empty project: pick from [`stack-catalog.md`](stack-catalog.md) (only groups that
     match question 2). "Other" is always fine.
4. **Lint / format.** Choose explicitly: ESLint, Biome, oxlint, Ruff, Prettier, none, or
   other. ESLint is one option, not the default.
5. **Testing.** Which runner, and what is required before "done": a test per bug fix,
   business logic only, or nothing yet.
6. **Git.** Branching model, commit convention, whether the agent may commit when asked.
7. **Hard constraints** and UI copy language (same as communication / English-only /
   i18n keys / no rule).

## Where answers go

| Answer | Destination |
| --- | --- |
| Language, stack, verify commands, constraints | `.cursor/rules/project/stack.mdc` (always loaded — keep it short) |
| Project type | Which rules stay: `frontend.mdc`, `backend.mdc`, or both |
| Agreements not visible in code | `.cursor/project-memory/knowledge-base.md` |
| Ideas and deferred decisions | `.cursor/project-memory/ideas.md`, `tasks.md` |

On an empty project the interview **only records** the chosen stack. The agent does not
install packages by itself — it proposes steps and waits for approval (constitution **W-6**).

Rule files stay in English on purpose (cheaper in every session). Conversation and memory
notes use the language from question 1. After install, methodology docs live under flat
`docs/` in the target project (the `docs/en` or `docs/ru` folders exist only inside the
Cursor-Constitution repo as language packs).
