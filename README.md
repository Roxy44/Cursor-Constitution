# Cursor Constitution

<p align="center">
  <strong>Portable AI agent rules for Cursor</strong><br/>
  Behavior · Security · Git · Testing · Frontend · Backend · Code form
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.ru.md">Русский</a>
</p>

<p align="center">
  <img alt="Cursor" src="https://img.shields.io/badge/Cursor-.cursor%2Frules-000000?style=flat-square&logo=cursor&logoColor=white" />
  <img alt="Token economy" src="https://img.shields.io/badge/always--on-~150%20lines-2ea44f?style=flat-square" />
  <img alt="Locales" src="https://img.shields.io/badge/docs-en%20%7C%20ru-0366d6?style=flat-square" />
  <img alt="License" src="https://img.shields.io/badge/share-with%20your%20team-6f42c1?style=flat-square" />
</p>

---

## Why this exists

Most teams either give the agent **no rules** (chaos) or one **giant always-on file** (burns tokens, agent ignores half of it).

This pack is the middle path:

| | |
| --- | --- |
| ✅ | Small **always-on** core — behavior, security, git, “ask before tooling” |
| ✅ | **Scoped** rules — frontend / backend / testing / style load only when relevant |
| ✅ | **Docs on demand** — methodologies stay on disk until the task needs them |
| ✅ | **One install** — language + memory + docs unpacked into your project |
| ✅ | **Onboarding** — stack and linter chosen with you, not guessed forever |

Built so you can send the repo to colleagues: they install, answer a short interview, and get a calm, predictable agent.

---

## Quick start (colleagues: do this)

### 1. Install into your project

Pick **one** way below. Replace the example paths with yours
(`Cursor-Constitution` = this repo, `AboutMe` = the app you install into).

#### Option A — Windows double-click (no terminal)

1. Open [`scripts/install.cmd`](scripts/install.cmd) (double-click in Explorer).  
2. When asked for **Target project**, paste the **full** path to your app root, e.g. `C:\projects\AboutMe`  
   (relative paths are resolved from `scripts\` — prefer absolute).  
3. Select language: **↑ / ↓ + Enter**, or type `ru` / `en`.  

#### Option B — PowerShell (Windows)

Use **PowerShell** (Cursor terminal → select `powershell`, or Windows Terminal).  
Do **not** paste these into Git Bash — `&` and `.ps1` are PowerShell-only.

Interactive (asks for target if needed, then language menu):

```powershell
& "C:\projects\Cursor-Constitution\scripts\install.ps1"
```

With target and language in one go (no prompts):

```powershell
& "C:\projects\Cursor-Constitution\scripts\install.ps1" -Target "C:\projects\AboutMe" -Locale ru
```

`-Locale` is `ru` or `en`. `-Target` is the root of **your** project (full path recommended).

#### Option C — Bash / Git Bash / macOS / Linux

Use **bash** (Git Bash on Windows, or the system shell on macOS/Linux).  
Do **not** paste PowerShell `& "...\install.ps1"` here — bash will fail.

Paths in Git Bash look like `/c/projects/...`, not `C:\projects\...`.

Interactive:

```bash
"/c/projects/Cursor-Constitution/scripts/install.sh"
```

With target and language in one go:

```bash
"/c/projects/Cursor-Constitution/scripts/install.sh" "/c/projects/AboutMe" ru
```

Arguments: `install.sh <target-project> <ru|en>`.  
On macOS/Linux use normal Unix paths, e.g. `$HOME/dev/Cursor-Constitution/scripts/install.sh`.

#### What appears in your project

```text
.cursor/rules/…              ← English agent rules
.cursor/project-memory/…     ← ideas, KB, lessons (your language)
docs/…                       ← methodologies (flat; no docs/ru folder)
```

> `docs/en` and `docs/ru` exist only inside **this** repository (language packs),  
> same idea as `template/.cursor` → `.cursor`.

### 2. Onboarding in Cursor

Open your project and ask:

> run onboarding from `.cursor/rules/onboarding.mdc`

Language is already set. The agent confirms stack, **package manager** (npm / yarn / pnpm /
bun — from lockfile or choice; checks PATH), **which linter you use** (or none), tests,
git, and an **acknowledgment keyword**. After that, every reply starts with
`Understood, <word>.` (English) or `Вас понял, <word>.` (Russian) so you can see the
rules are still loaded. It does **not** install packages unless you say yes. Later
installs always use the recorded package manager (**W-6**).

### 3. Work

Write features as usual. The agent follows the constitution, opens scoped rules by file type, and reads `docs/` only when designing something deeper.

---

## How context loading works

| Layer | Where | In context when |
| :---: | --- | --- |
| 🟥 Core | `constitution.mdc`, `project/stack.mdc`, `acknowledgment.mdc` | Every chat |
| 🟧 Scoped | `code-style`, `frontend`, `backend`, `testing` | Matching files (globs) |
| 🟨 On request | `onboarding`, `retrospective` | Agent decides by description |
| 🟩 Reference | `docs/**` | Agent opens the file |
| 🟦 Memory | `.cursor/project-memory/` | Lessons / KB when relevant |

**Token idea:** grow the library freely; keep the always-on budget ~150 lines.

---

## How package installs work

| Piece | Role |
| --- | --- |
| `Package manager` in `stack.mdc` | Single source of truth (npm / pnpm / yarn / bun / …) |
| Onboarding | Detects from lockfile or asks; verifies the CLI is on PATH |
| Missing CLI | Agent stops, explains how to install it, or offers alternatives (e.g. no yarn → npm / bun) |
| After approval (**W-6**) | Every `add` / `install` uses **only** that manager — no silent switches |

---

## How linting works (important)

There is **no** silent “our ESLint shipped into every project”.

| Piece | Role |
| --- | --- |
| `code-style.mdc` | **Intents** the agent should honor (quotes, `eqeqeq`, hooks, …) when writing code |
| Your real linter | **Enforcement** — whatever is already in the repo, or what you choose at onboarding |
| Onboarding | Records `Lint / format` in `stack.mdc` (Biome / ESLint / oxlint / Ruff / none / …) |
| `docs/methodologies/eslint-baseline.md` | Optional starter **only if** you chose ESLint and approved setup |
| Agent before “done” | Runs **your** existing `lint` / `build` / tests (`T-1`); fixes what it broke |

So:

1. **While coding** — the agent follows rule intents (and your stack file).  
2. **While verifying** — it runs the project’s lint script if one exists.  
3. **Wiring a linter** — only after you pick one and say yes (`W-6`). Intents are then mapped into that tool’s config; they are not magically auto-applied as a hidden second linter.

If you choose **none**, the agent still tries to follow `code-style.mdc`, but nothing machine-enforces it until you add a tool.

---

## What’s in the box

| File | Job |
| --- | --- |
| `constitution.mdc` | Non-negotiables + map to everything else |
| `acknowledgment.mdc` | Liveness canary — exact `Understood, …` / `Вас понял, …` line (filled at onboarding) |
| `project/stack.mdc` | Your stack, language, lint choice, CSS naming / BEM, keyword (filled by install + onboarding) |
| `code-style.mdc` | Form + linter intents |
| `frontend.mdc` / `backend.mdc` / `testing.mdc` | Short architecture per area |
| `onboarding.mdc` | Stack / tooling interview |
| `retrospective.mdc` | How to write lessons after failures |
| `docs/methodologies/*` | Deeper guides (design principles, patterns, testing types, git, tooling) |

---

## Extending in a live project

1. Project-specific rules → `.cursor/rules/project/` (not the shared constitution).  
2. Lessons → `project-memory/lessons/`; third repeat → promote to a project rule.  
3. New deep topics → `docs/methodologies/`.  
4. Keep always-on lean — measure:

```powershell
Get-ChildItem -Recurse .cursor\rules -Filter *.mdc |
    Where-Object { (Get-Content $_.FullName) -match '^alwaysApply: true' } |
    ForEach-Object { (Get-Content $_.FullName).Count } |
    Measure-Object -Sum
```

---

## Other agents

Copy the body of `constitution.mdc` (without YAML frontmatter) into root `AGENTS.md` for Claude Code, Copilot, Codex, and similar.

---

## License / sharing

Made to be cloned, installed into product repos, and shared with teammates.  
Keep rule `.mdc` files in English (token cost); talk and memory in your team’s language.
