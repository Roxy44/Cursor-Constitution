# Methodology: frontend

Reference only. Not loaded automatically — open when `frontend.mdc` is not enough:
designing a new feature, layer, or folder structure.

## Choosing project structure

| Approach | Fits when | Cost |
| --- | --- | --- |
| Flat (`components/`, `pages/`, `utils/`) | Small project, 1–2 developers, ~30 components | `components/` becomes a dump as it grows |
| Feature-based (`features/<feature>/…`) | Mid-size product, several teams | Need discipline: what is shared vs feature-owned |
| Feature-Sliced Design (layers + slices) | Large long-lived product | Steep learning curve, many import rules |
| Domain modules (`modules/<domain>`) | Monolith with clear domains | Boundaries blur without import linting |

Rule of thumb: **do not over-structure early**. Flat → feature-based is cheap; the reverse
is not. Take FSD when more than one team owns the UI and someone enforces layers.

## Module boundaries

- A feature has a public entry (`index.ts`); internals are not imported from outside.
- Feature → feature imports are forbidden. Shared code goes to `shared` / `entities`, or
  composition happens at the page level.
- Shared means already used in two places **and** domain-agnostic. Otherwise it is
  premature abstraction.
- Circular imports are forbidden (`import/no-cycle`) — the honest signal of broken
  boundaries.

## State

Cheapest first:

1. Local component state.
2. Lift to the nearest common parent.
3. Context — for rarely changing, widely needed values (theme, locale, current user).
4. External store — when state outlives unmount and many branches need it.
5. Server cache (react-query / RTK Query / SWR) — for backend data.

Common mistakes: hand-copying server data into a global store; context with hot values
(re-renders the whole subtree); duplicating state instead of deriving it.

## Data and loading

- Three states are mandatory: loading, empty, error. Add retry for errors.
- Skeletons over spinners when the content shape is known.
- Optimistic updates only with rollback on failure.
- Validate at the boundary (zod / io-ts / type guard), not "by TypeScript alone".

## Component composition

- More than three boolean props → split the component or switch to composition
  (`children`, slots).
- Config props (`variant`, `size`) fit a design system, not business logic.
- Containers fetch; presentational components render. Mixing both hurts tests and reuse.
- A hook is the right place for logic that must be reused without markup.

## Performance

Measure first (React DevTools Profiler, Lighthouse, `performance.mark`), then optimize:

1. Cut wasted re-renders: stable keys, push state down, split contexts.
2. Memoization (`useMemo`, `memo`) — targeted, from profiler data.
3. Code-split: lazy routes and heavy widgets.
4. Virtualize long lists (~100+ items).
5. Images: right size, format, `loading="lazy"`.

## Accessibility

Always check: keyboard navigation, visible focus, accessible names on interactive
elements, text contrast, heading order, `aria-live` for dynamic messages. Modals: focus
trap and close on `Escape`.
