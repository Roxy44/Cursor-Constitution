# Stack catalog for the onboarding interview

Option lists for agents. Open this file **only** when the repo is empty or the stack
cannot be read from files. On an existing project, detect from the manifest first — do not
open this catalog.

Offer options from the lists below. Do not invent exotic stacks outside the catalog unless
the user names them. Multiple picks in one group are fine (e.g. ORM + database). An
"other" answer is always allowed — then write the user's wording as-is.

## Project type

- frontend
- backend
- fullstack
- library
- CLI
- mobile

## Languages

- TypeScript
- JavaScript
- Python
- Go
- Rust
- Java / Kotlin
- C#
- PHP
- Ruby
- Swift / Kotlin (mobile)
- other

## Frontend — framework

- React (Vite / Next.js / Remix)
- Vue (Vite / Nuxt)
- Svelte / SvelteKit
- Angular
- Solid
- vanilla / no framework
- other

## Frontend — styling

- Tailwind
- CSS Modules
- SCSS / Sass
- styled-components / Emotion
- vanilla CSS
- other

## Frontend — state

- local state (+ Context)
- Zustand
- Redux Toolkit
- Jotai / Recoil
- Pinia (Vue)
- other / not needed yet

## Frontend — server data

- fetch / axios by hand
- TanStack Query (react-query)
- SWR
- RTK Query
- Apollo / urql (GraphQL)
- tRPC
- other / not needed yet

## Backend — runtime / language

- Node.js (TypeScript / JavaScript)
- Deno / Bun
- Python
- Go
- Java / Kotlin
- C# / .NET
- PHP
- other

## Backend — framework

- NestJS / Express / Fastify / Hono
- Next.js Route Handlers / tRPC (BFF)
- Django / FastAPI / Flask
- Gin / Echo / Fiber (Go)
- Spring Boot
- ASP.NET Core
- Laravel / Symfony
- other

## Backend — database

- PostgreSQL
- MySQL / MariaDB
- SQLite
- MongoDB
- Redis (primary or cache)
- other / no database yet

## Backend — data access

- Prisma / Drizzle / TypeORM / Knex
- SQLAlchemy / Django ORM
- GORM / sqlc
- raw SQL
- other / not needed yet

## Package manager

- npm / pnpm / yarn / bun
- pip / poetry / uv
- go modules
- cargo
- other

## Linter / formatter

- ESLint + Prettier
- Biome
- oxlint (+ Prettier or without)
- Ruff / Black (Python)
- golangci-lint / gofmt
- none — do not add without asking
- other

## Tests

- Vitest / Jest
- Playwright / Cypress (e2e)
- pytest
- go test
- nothing yet
- other

## Expectation before "done"

- a test for every bugfix
- cover business logic
- only what CI already runs
- require nothing yet

## Git

- trunk-based / GitHub Flow / Git Flow
- Conventional Commits — yes / no
- agent commits only when explicitly asked (constitution default)
