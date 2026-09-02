# Methodology: git workflow

Reference for branching, commits, and releases. Hard prohibitions live in the constitution
§5: the agent **never** commits and **never** pushes (**G-1**, **G-5**). Work, deploy,
GitHub Pages, CI, or "make it live" do not change that — prepare locally, draft messages,
list commands for the developer, and stop.

## Agent must not (ever)

- `git commit` / amend / staging commits as part of any workflow or deploy script
- `git push` / push tags / push `gh-pages` or any built branch
- `git subtree split` + push, or npm/yarn scripts whose purpose is remote publish via git

When commit or push is needed, say so explicitly, show a proposed message and the exact
commands — the **developer** runs them.

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

### Lockfiles (greenfield default)

For a project started from zero, **prefer ignoring lockfiles** in git (constitution
**G-6**): `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lock` / `bun.lockb`,
and the same idea for other ecosystems. Commit the manifest (`package.json`, …). After
`install`, the lockfile appears on the developer machine and stays local.

Why: a committed lock can pin an aging tree for years and keep known-vulnerable packages
in every clone. Fresh install from the manifest pulls current resolutions within the
declared ranges.

Exceptions: if the team needs bit-for-bit reproducible CI, set `Lockfiles in git: commit`
in `stack.mdc` and track the lockfile. Never strip lockfiles from an existing repo that
already commits them without an explicit ask.
