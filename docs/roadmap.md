# Roadmap

## Governing priority: functional UI first

The Criminal OS is a core game system. Gameplay expansion remains blocked by
ADR 0010 until the bounded functional OS is accepted. Recovered desktop research
is in docs/design/ui_os_research.md. Engineering acceptance does not substitute
for owner acceptance of interaction and visual direction.

## Implemented foundation

0. Foundation 0: typed Godot repository and health checks.
1. Infrastructure 1: project memory and architecture rules.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: action -> state -> UI -> manual save/load.
4. Simulation Spine: time, restorable RNG, IDs, ordered commands and fingerprints.
5. Persistence & Developer Tools: inspection, recovery and hands-off delivery.
6A. Four-rail workspace geometry and independent layout memory (PR #14).
6B. Movable widgets, deterministic packing and semantic forms (PR #15).

## Phase 6C: App lifecycle, selection and navigation — CURRENT IMPLEMENTATION

- Stable launcher and City/Home root.
- Operations as an explicit center-focus app; Session Record as a right-rail app.
- App-local Back, remembered views and contextual identity handoff.
- City camera/selection/focus continuity across center-focus transitions.
- Mounted app views retain scroll/focus identity while inactive views suspend.
- Recent Activity demonstrates widget-to-app deep linking with real existing data.
- No arbitrary overlapping desktop windows and no placeholder future-domain apps.

See ADR 0013 and docs/state.md for implementation boundaries.

## Phase 6D: Reactive product components and integrated acceptance — NEXT

- Fully author Work Scan's hierarchy, semantic forms and visual treatment.
- Reconcile changing data by stable IDs without losing focus, scroll or pointer
  intent; coalesce updates rather than rebuilding the shell.
- Functional transitions and reduced-motion behavior.
- Explicit empty/loading/error/unavailable states using isolated labeled fixtures
  only where the current simulation cannot naturally provide one.
- Apply the same reactive contract to a second existing readout without forcing
  identical visuals or generic cards.
- Exercise rail resizing, widget manipulation, app navigation, state changes,
  focus restoration, profile restore and save integrity together.
- Profile actual update/manipulation cost rather than assert performance.

### Exit to gameplay expansion

Exit when the integrated OS rearranges/restores its workspace, keeps widgets
useful, resumes apps, reacts without losing interaction state, preserves game
integrity, and the owner accepts the direction and feel. This does not require
every future app, gameplay domain or final art asset.

## Phase 7: First systemic vertical slice — BLOCKED BY PHASE 6 ACCEPTANCE

After UI acceptance, expand a city-connected opportunity through management,
consequences, persistence and deterministic replay using the established OS.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one at a time with explicit ownership, APIs, tests and persistence.

## Phase 9: Scale and production

Content tools, asset policy, compatibility, measured profiling/soak tests and
release packaging follow actual scale. Reuse existing delivery workflows.

## Workflow

Approved slices authorize engineering to handle implementation, validation,
fixes, builds and eligible merges. Human input is for product direction and
experience, not routine scripts or save repair.
