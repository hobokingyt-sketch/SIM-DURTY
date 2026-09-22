# Roadmap

Build order is separate from product ambition. Actual acceptance/merge status
comes from matching PRs and exact-revision tests.

## Completed baseline

0. Foundation 0: bootable typed-GDScript repository and initial health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture guardrails.
2. Infrastructure 2: traceable exported Windows previews and packaged startup gate.
3. Walking Skeleton: authored action -> state -> UI -> explicit save/load.

## Phase 4: Simulation Spine

Controlled integer clock, seeded/restorable RNG, stable ID cursor, explicit
command ordering, detached bounded event records and state fingerprint. Integrate
these into the existing session rather than building an unused parallel framework.
Schema 2 preserves schema 1 progress. See ADR 0007 for exact scope and limits.

## Phase 5: Persistence & Developer Tools — NEXT

Backup recovery, save inspection, migration fixtures, reusable scenario tools,
state/entity inspection and developer controls as actual systems need them.
The schema, manual stepping and debug report introduced earlier are reused.

## Phase 6: OS + City Skeleton

Native Godot OS shell and city workspace; rail/widget/app/context/alert contracts;
shared Theme/tokens and readable responsive reference geometry. No fake data.

## Phase 7: First systemic vertical slice

One city-connected opportunity flows through glance, management, consequences,
persistence and deterministic replay. Add only the domain prerequisites it needs.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one domain at a time with one owner, public API, tests, diagnostics and persistence.

## Phase 9: Scale and production

Content validation/tools, binary-asset policy, historical save compatibility,
profiling and measured budgets, soak tests and durable release packaging.

## Rules

Vision does not authorize out-of-order systems. Pull forward only narrow
prerequisites. Document architecture changes with ADRs. Keep state/roadmap truthful;
engineering acceptance and owner game-feel approval are separate.
