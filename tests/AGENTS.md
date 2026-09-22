# Test Engineering Contract

Scope: `tests/**`

Tests protect behavior and architecture. They are not ceremonial coverage.

## Rules

- Tests must be deterministic.
- Do not rely on network access.
- Avoid wall-clock sleeps and timing-sensitive assertions where a controllable clock can exist.
- Use fixed seeds for stochastic simulation tests.
- Test observable contracts rather than private implementation trivia.
- Regression tests should describe the bug/system behavior they protect.
- Persistence tests must use explicit fixture/schema versions.
- Scenario tests should be small enough to diagnose when they fail.
- Architecture tests may enforce dependency boundaries mechanically.
- A failing test is not disabled merely because a feature change made it inconvenient; update the contract deliberately.

## Test layers

Add these only as real systems require them:
- unit,
- integration,
- smoke,
- architecture,
- determinism,
- persistence,
- scenario,
- content validation,
- performance/soak.
