# Roadmap

Build order is separate from ambition. Actual acceptance/merge status comes
from matching PRs and exact-revision tests.

## Completed baseline

0. Foundation 0: bootable typed-GDScript repository and health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture rules.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: authored action -> state -> UI -> explicit save/load.
4. Simulation Spine: controlled time, seeded continuation, stable IDs, commands,
   bounded journal, fingerprints and compatible schema-2 persistence (PR #10).
5. Persistence & Developer Tools: quiet inspection, safe recovery, existing-gate
   scenarios and hands-off development contract (PR #11).

## Phase 6: OS + City Skeleton

Native Godot OS framing, glance/context/Operations handoff and authored city
blockout. One selection owner; city camera stays alive across app transitions.
Reuse the working errand and existing saves. See ADR 0009 for actual limits:
this is not a living city or an arbitrary widget-layout editor.

## Phase 7: First systemic vertical slice — NEXT

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
provides direction and experiential feedback. Do not add infrastructure milestones
that delay the next real capability. Keep developer instrumentation optional.
Engineering acceptance and owner game-feel approval remain separate.
