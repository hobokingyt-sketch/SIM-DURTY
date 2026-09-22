# Roadmap

Build order is separate from product ambition. Actual acceptance/merge status
comes from matching PRs and exact-revision tests.

## Completed baseline

0. Foundation 0: bootable typed-GDScript repository and initial health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture guardrails.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: authored action -> state -> UI -> explicit save/load.
4. Simulation Spine: clock, seeded continuation, stable IDs, ordered commands,
   bounded journal, fingerprints and compatible schema-2 persistence (PR #10).

## Phase 5: Persistence & Developer Tools

Bounded final prerequisite: read-only save inspection, one-action safe backup
recovery, quiet developer controls and recovery scenarios in the existing gates.
Reuse schema migration, replay tests and Windows packaging rather than building
parallel infrastructure. Hands-off development is not a change to autosave or
idle gameplay. See ADR 0008. After validation, proceed to Phase 6.

## Phase 6: OS + City Skeleton — NEXT

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
prerequisites. Engineering handles routine validation and delivery; the owner
provides game direction and experiential feedback. Do not invent infrastructure
milestones that delay the next real capability. Engineering acceptance and owner
game-feel approval are separate. Keep state and roadmap truthful.
