# Methodology: backend

Reference only. Open when `backend.mdc` is not enough: designing a layer, abstraction,
integration, or data schema.

Language-agnostic. Examples on Refactoring.Guru are shown per language (PHP, TypeScript,
Python, Go, …) — the intent of each pattern is the same; map it to the project's stack.
Catalog: [Design patterns](https://refactoring.guru/design-patterns/catalog) (RU mirror:
[refactoringu.ru PHP index](https://refactoringu.ru/ru/design-patterns/php.html)).

## Architecture approaches

| Approach | Fits when | Cost |
| --- | --- | --- |
| Layered (controller → service → repository) | Default for most services | Services become "god services" as they grow |
| Hexagonal / ports & adapters | Many integrations, need swappability | More interfaces and wiring |
| Clean Architecture | Long-lived domain with complex rules | Many layers; expensive for CRUD |
| Vertical feature slices | Teams want feature autonomy | Duplication across slices |
| Microservices | Different lifecycles and scaling needs | Distributed transactions, ops cost |

Start with a layered monolith and clear boundaries. Microservices answer an
organizational problem more often than a technical one.

## Dependency rule

Domain knows nothing about transport or the database. In practice: business-logic files
import neither framework types (`Request`, `Response`), ORM models, nor SQL. Expose
interfaces; inject implementations at the edge.

Check: can you call the business rule from a test without starting HTTP or a database?
If not, boundaries are broken.

## Design patterns — how to use the catalog

Patterns solve **recurring design problems**. They are not a checklist to implement all
22 classics. Refactoring.Guru also covers **criticism**: forced patterns obscure simple
code and create accidental complexity.

Decision test before adding one:

1. What concrete pain exists today (duplication, hard-to-test coupling, exploding
   conditionals)?
2. Which pattern removes that pain with the **smallest** new surface?
3. Can a plain function + interface do it? If yes, stop there.

### Creational (object creation)

| Pattern | Backend use | Avoid when |
| --- | --- | --- |
| Factory Method / Abstract Factory | Multiple families of notifiers, payment providers, storage drivers | One implementation forever |
| Builder | Reports, queries, complex aggregates with many optional parts | Two-field DTOs |
| Prototype | Expensive config/template objects cloned per request | Cheap value objects |
| Singleton | Almost never in app code; prefer DI container lifetime | Hidden global state, hard tests |

### Structural (composition)

| Pattern | Backend use | Avoid when |
| --- | --- | --- |
| Adapter | Wrap vendor SDK behind your port | You own the API and can change it |
| Facade | One simple API over a messy subsystem (billing, mail) | Facade becomes a new god object |
| Decorator / Proxy | Logging, retries, caching, auth around a port | You keep editing the core class instead |
| Bridge | Two independent axes of variation (e.g. shape of export × channel) | Only one axis changes |
| Composite | Tree menus, nested permissions, folder-like domains | Flat lists |
| Flyweight | Huge numbers of similar immutable value-like objects | Ordinary entity counts |

### Behavioral (responsibilities)

| Pattern | Backend use | Avoid when |
| --- | --- | --- |
| Strategy | Pricing, tax, sorting, auth policies swapped at runtime | Single algorithm forever |
| Template Method | Shared workflow with a few replaceable steps | Steps diverge completely — use composition |
| Chain of Responsibility | Middleware / filter pipelines, validation pipelines | Order is unclear or side effects hide |
| Command | Jobs, undo, audit trail, queue messages as intents | Trivial one-liner handlers |
| Observer / Mediator | Domain events; reduce many-to-many service calls | Chatty events for every field write |
| State | Order / ticket / payment lifecycles with real transitions | Simple boolean flags |
| Iterator | Custom collections, streaming large result sets | Language `for` already enough |
| Memento | Draft restore, undo within a session | Full event sourcing "by accident" |
| Visitor | Rare: stable object graph, many new operations | Graph changes often — prefer plain methods |

### Persistence note

"Repository" in everyday backend talk is a **persistence port**, not always the GoF
pattern. Keep it honest: if callers build raw filter trees and know SQL semantics, the
abstraction is leaking — fix the query API or accept a thinner data-mapper style.

## Anti-patterns (backend)

- God service / god controller: one class owns HTTP, rules, and SQL.
- Anemic domain with all rules in controllers "for speed".
- Premature microservices and distributed transactions.
- Pattern theater: interfaces with a single implementation "for SOLID" with no test or
  swap need.
- Catch-all `Exception` handlers that return 500 for domain conflicts (should be 4xx).
- Shared mutable statics / Singletons instead of request-scoped DI.

## API design

- Resources are nouns; actions are methods. Verbs in URLs only for explicit commands
  (`/orders/{id}/cancel`).
- Paginate any list that can grow. Prefer cursor pagination when data changes often.
- Filters and sort use a field whitelist — never raw substitution into a query.
- Versioning is a decision up front: path (`/v1/`) is simplest. Do not break a contract
  without a version.
- One error shape for the whole API: code, human message, field details, request id.

| Situation | Status |
| --- | --- |
| Invalid input | 400 (or 422 for semantics) |
| Not authenticated | 401 |
| Authenticated but not allowed | 403 |
| Missing resource | 404 |
| State conflict / duplicate | 409 |
| Rate limited | 429 |
| Internal failure | 500 |

## Idempotency and reliability

- `GET`, `PUT`, `DELETE` are idempotent by definition; `POST` is not — payments and
  creates need an idempotency key.
- External calls: timeout, bounded retries with exponential backoff + jitter, circuit
  breaker on mass failure.
- Retry without idempotency creates duplicates — the usual cause of double charges.

## Data

- Migrations are the only way to change schema; each is reversible or has a rollback plan.
- Indexes match real queries, not "just in case"; every index slows writes.
- A transaction covers one business invariant. Long transactions that call external
  services cause locks.
- Soft delete is a deliberate choice: it leaks into every query and unique index.
- Catch N+1 at review time: added a relation to a fetch — check the query plan.

## Observability

- Structured logs with levels and a request correlation id.
- Log ids and metadata, not request bodies or personal data.
- Minimum metrics: request rate, error rate, latency percentiles (p95/p99).
- Split health checks: liveness (process up) vs readiness (ready for traffic).

## Security

Authn answers "who", authz answers "allowed", and the second is checked on every object
access — not once at login. Also: rate limits, body size limits, file-type checks on
upload, no secrets in logs or responses, CORS allowlist, no exception details in 5xx
bodies.
