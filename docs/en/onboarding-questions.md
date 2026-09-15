# Onboarding questionnaire

The same questions the agent asks via `onboarding.mdc`, written for a human. Use this if
you want to fill `project/stack.mdc` by hand.

In Cursor Chat the agent should ask these as **clickable multiple-choice** (one round, up
to seven groups, with an "other" escape) **plus** a free-text acknowledgment keyword in
the same turn. A plain numbered list is only a fallback when that UI is unavailable
(CLI / other clients).

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
   - Frontend CSS naming: ask **only** for classic CSS / SCSS / CSS Modules. If styling is
     Tailwind, UnoCSS, or CSS-in-JS (styled-components, Emotion, …) → write `n/a` — do
     **not** ask about BEM (mixing BEM with utilities/`styled` confuses agents).
     Options when asking: `bem` / `existing` / `none`. Backend-only → `n/a`.
     KISS / DRY / SOLID are always on — do not ask.
4. **Package manager.** npm / pnpm / yarn / bun (or poetry / uv / go / cargo…). Infer from
   the lockfile when present; confirm. `package-lock.json` alone can mean **npm or yarn**
   — ask if `packageManager` / `.yarnrc*` do not settle it. Agent verifies the CLI is on
   PATH; if missing — install hint or switch to an alternative (e.g. yarn → npm / bun).
   All future installs use this choice only.
5. **Lint / format.** Choose explicitly: ESLint, Biome, oxlint, Ruff, Prettier, none, or
   other. ESLint is one option, not the default.
6. **Testing.** Which runner, and what is required before "done": a test per bug fix,
   business logic only, or nothing yet.
7. **Git + hard constraints** and UI copy language (same as communication / English-only /
   i18n keys / no rule). Agent **never** commits or pushes (**G-1**, **G-5**) — only
   drafts messages and commands for the developer. **Greenfield:** default ignore package lockfiles in `.gitignore`
   (manifest stays tracked; lock regenerates on local install). Confirm if the team wants
   lockfiles committed instead. **Existing:** leave current lockfile practice alone.
8. **Acknowledgment keyword.** Type a word you will recognize. Every later agent reply
   starts with a canary so you can see rules are still loaded — if the line vanishes,
   the session is drifting. Russian communication language → `Вас понял, <word>.`;
   English → `Understood, <word>.` No suggested word and no skip: this has no default.

## Where answers go

| Answer | Destination |
| --- | --- |
| Language, stack, verify commands, constraints, acknowledgment keyword | `.cursor/rules/project/stack.mdc` (always loaded — keep it short) |
| Canary line (`Вас понял, …` / `Understood, …`) | `.cursor/rules/acknowledgment.mdc` (always loaded) |
| CSS naming (BEM or not) | `CSS naming` in `stack.mdc` (`bem` / `existing` / `none` / `n/a`) |
| Lockfiles in git | `Lockfiles in git` in `stack.mdc` (`ignore` default greenfield / `commit`) |
| Project type | Which rules stay: `frontend.mdc`, `backend.mdc`, or both |
| Agreements not visible in code | `.cursor/project-memory/knowledge-base.md` |
| Ideas and deferred decisions | `.cursor/project-memory/ideas.md`, `tasks.md` |

On an empty project the interview **only records** the chosen stack. The agent does not
install packages by itself — it proposes steps and waits for approval (constitution **W-6**).

Rule files stay in English on purpose (cheaper in every session). Conversation and memory
notes use the language from question 1. After install, methodology docs live under flat
`docs/` in the target project (the `docs/en` or `docs/ru` folders exist only inside the
Cursor-Constitution repo as language packs).
