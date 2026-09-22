# Core Engineering Contract

Scope: `game/core/**`

Core contains reusable technical foundations.

## Rules

- Core must not depend on `game/ui/`, `game/simulation/`, or `game/features/`.
- Core should expose small, typed APIs.
- Core must not contain feature-specific player-facing wording or UI.
- Deterministic foundations must be deterministic by construction.
- Persistent identifiers must be stable and explicit.
- Do not use wall-clock time for gameplay simulation.
- Do not introduce global state simply because core code has many consumers.
- A core primitive should exist because multiple real systems need it or because a roadmap phase explicitly requires it.
- Prefer inspectable code over metaprogramming or clever abstraction.
- Add focused tests for every nontrivial core behavior.
