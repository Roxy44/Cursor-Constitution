# Methodology: testing

Reference only. Open when choosing a **test type** or deciding coverage is enough. How to
write a concrete test lives in `testing.mdc`.

## Test types

| Type | Checks | Scope | Speed | Required when |
| --- | --- | --- | --- | --- |
| Unit | One function, class, hook in isolation | One unit | ms | Business rules, calculations, transforms |
| Integration | Modules together: service + DB, component + store | Several units | tens of ms – seconds | Data layer, API access, complex components |
| Contract | Client and server expectations match | Boundary of two systems | fast | Public API, separate teams, microservices |
| End-to-end | Full user journey | Whole app | seconds – minutes | Critical paths: login, payment, key action |
| Smoke | App boots and works basically | Whole | fast | After deploy, first CI step |
| Regression | An old bug did not return | Local | fast | Every fixed bug |
| Snapshot | Markup/output did not change unexpectedly | Component, response | fast | Small stable fragments |
| Load | Behavior under traffic | System | slow | Before a big launch, when speed complaints appear |
| Security / static analysis | Vulnerabilities, deps, secrets | Repo | fast | Always in CI |
| Accessibility | Keyboard, roles, contrast | UI | fast | Public interfaces |

## Proportions

Sensible default: many unit, fewer integration, few e2e (the pyramid). For UI products a
"trophy" shape is often more honest: weight in integration tests, because that is where
real wiring breaks.

Skew signals: editing one module breaks dozens of tests (too many unit tests on
implementation detail), or CI takes half an hour and flakes (too many e2e).

## What "enough" means

Coverage percentage is a signal, not a goal. Orient on: business rules and authz near full
branch coverage; transport layer — happy path + errors; UI — critical journeys; generated
code and trivial wrappers — skip.

Better than a percentage: "if this rule breaks, does any test fail?" If not, coverage is
fake.

## Test data

Factories and builders over copied fixtures: a test sets only what matters for its case;
defaults fill the rest. Huge JSON fixtures make tests unreadable and brittle.

## Isolation and doubles

- Mock boundaries: network, clock, randomness, filesystem, external services.
- A real DB in integration tests beats an ORM mock: ORM mocks test the mock, not the
  queries. A throwaway container DB is normal practice.
- Each test prepares its own state and does not depend on run order.

## Anti-patterns

A test that restates the implementation line by line; asserting on private methods;
`sleep` instead of waiting for a condition; one test with twenty assertions; a giant
tree snapshot instead of meaningful checks; skipped tests that live for months; "fixing"
a failure by weakening the assertion.

## Tests in CI

Order: static analysis and types → unit → integration → build → e2e on the built app.
Fail fast. A flaky test is fixed or deleted — an intermittently red CI devalues every
other test.
