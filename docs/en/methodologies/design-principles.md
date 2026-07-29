# Methodology: design principles

Reference only. Constitution **P-6…P-8** already require KISS, DRY, and SOLID on every
code change. Open this file when a trade-off is non-obvious, when reviewing structure, or
when `CSS naming` in `stack.mdc` is `bem`.

These are engineering defaults — not an excuse to rewrite working code (**P-3**).

## KISS — Keep It Simple, Stupid

Prefer the simplest design that correctly solves the **stated** problem.

| Do | Don't |
| --- | --- |
| Straight-line code that a teammate can read in one pass | Nest frameworks, DI graphs, or config "for later" |
| One clear control flow | Clever one-liners that hide intent |
| Delete dead branches when the task touches them | Leave speculative hooks and unused flags |

Decision test: if removing a layer / interface / option still meets the requirement,
remove it. Complexity needs a reason you can say in one sentence.

## DRY — Don't Repeat Yourself

Do not duplicate **non-trivial** knowledge (rules, formulas, mapping tables). Duplicating
trivial glue or two short similar JSX blocks is fine until the shape stabilizes.

| Signal | Action |
| --- | --- |
| Same logic in two places and both must stay in sync | Extract a shared function / module |
| Same shape once, maybe never again | Leave it; extract on the second real use |
| "Shared" helper with many flags for different callers | Wrong abstraction — split or inline |

Wrong abstraction costs more than duplication. Prefer a short copy with a comment over a
generic helper that nobody understands.

## SOLID

Apply at a scale that fits the task. A 30-line script does not need five interfaces.

| Letter | Meaning in practice |
| --- | --- |
| **S**ingle Responsibility | A module / type / function has one reason to change. Split "fetch + render + format" god units. |
| **O**pen–Closed | Extend via composition / new types rather than editing every call site for each variant — when variants are real, not imagined. |
| **L**iskov Substitution | Subtypes must honor the parent's contract. No surprise throws or ignored params in overrides. |
| **I**nterface Segregation | Prefer narrow interfaces the caller needs. Do not force clients to depend on unused methods. |
| **D**ependency Inversion | High-level policy depends on abstractions the project already uses (ports, injected clients), not on concrete HTTP/DB details — at boundaries that matter for tests or swapability. |

Decision test before adding an interface or layer: does it enable a real second
implementation, a test without I/O, or a clear team boundary? If not, KISS wins.

Patterns from `docs/methodologies/backend.md` are tools under SOLID/KISS — not a checklist
to implement all classics.

## BEM (optional)

Only when **CSS naming** in `project/stack.mdc` is `bem`. Otherwise skip this section.

**Hard skip:** if the styling stack is Tailwind / UnoCSS / CSS-in-JS, BEM does not apply.
Do not invent `block__element` names next to utility classes or `styled` components —
that mix is a bug. Those projects keep `CSS naming: n/a`.

BEM = Block / Element / Modifier for **class names** in classic CSS, SCSS, or CSS Modules
(where local names still follow the convention).

| Part | Form | Example |
| --- | --- | --- |
| Block | `block-name` | `card` |
| Element | `block-name__element` | `card__title` |
| Modifier | `block-name--modifier` or `block-name__element--modifier` | `card--featured`, `card__title--large` |

Rules of thumb:

- One block per component root when practical; nest elements under that block.
- Modifiers change state or variant — do not create a new block for a small visual tweak.
- Do not mix BEM with ad-hoc global class names in the same feature.
- In a hybrid (e.g. Tailwind + a few SCSS blocks), apply BEM **only** to the classic
  custom classes, never to utility class strings.

If the repo already uses a dialect (e.g. `_` instead of `__`, or camelCase blocks), match
**existing** files — consistency beats textbook purity (**P-2**).
