# Methodology: git workflow

Reference for branching, commits, and releases. Hard prohibitions (no commit without
asking, no history rewrite) live in the constitution §5.

## Branching models

| Model | Fits when | Cost |
| --- | --- | --- |
| Trunk-based (short branches from `main`) | Frequent releases, CI and tests exist | Feature flags for unfinished work |
| GitHub Flow (branch → PR → `main`) | Default for product teams | Needs discipline on PR size |
| Git Flow (`develop`, `release/*`, `hotfix/*`) | Versioned releases, long stabilization | Many merges, slow |
| Release branches | Supporting several versions at once | Expensive backports |

Default: short branches from `main` and a small PR. A branch lives hours or days, not
weeks — longer means costlier conflicts.

## Branch names

`<type>/<short-description>`: `feat/order-export`, `fix/login-timeout`,
`refactor/api-client`, `chore/deps-bump`. Ticket id first if the project requires it:
`feat/PROJ-142-order-export`.

## Commits

Conventional Commits: `type(scope): short summary` in imperative mood, ~72 chars, no
trailing period.

Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `build`, `ci`, `chore`.
Breaking change: `!` after the scope and a `BREAKING CHANGE:` footer.

Body covers **why**, not a retelling of the diff. One commit = one logical change;
formatting and renames are separate commits so review stays readable.

## Pull request

- Size: aim for ~400 changed lines excluding generated files. Larger → split.
- Description: what and why, how to verify, what is out of scope, screenshots for UI.
- Self-check before review: lint, types, tests, build pass locally.
- Review looks at correctness, boundaries, tests, readability. Style is the linter's job.
- Comments close with a fix or an argument; silent ignored threads are not left around.

## Merge

| Method | When |
| --- | --- |
| Squash | Default: noisy branch history becomes one meaningful commit |
| Merge commit | When branch history matters (large feature with logical steps) |
| Rebase and merge | Linear history; every commit is meaningful and green |

Before merge, the branch includes current `main`. The branch author resolves conflicts —
they know the context.

## Releases

Semantic versioning: `major` breaking, `minor` features, `patch` fixes. Tag the release
commit; changelog from conventional commits. Hotfix from the release tag, then back into
`main`.

## Hygiene

`.gitignore` covers build artifacts, dependencies, local configs, and `.env`. A secret that
reached history is considered leaked: revoke and rotate first, then clean history. Large
binaries go to LFS or external storage, not the repo.
