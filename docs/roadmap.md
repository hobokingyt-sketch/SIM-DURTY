# Roadmap

## Governing priority: functional UI first

The Criminal OS is a core game system, not optional presentation polish. Phase 6
remains open under ADR 0010. Gameplay expansion waits for functional and visual
OS acceptance. Recovered desktop research is in docs/design/ui_os_research.md;
it is not the separate mobile project. Engineering acceptance is not automatic
owner acceptance of UI direction. Exact run/merge evidence belongs to each PR.

## Implemented foundation

0. Foundation 0: bootable typed-GDScript repository and health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture rules.
2. Infrastructure 2: traceable Windows builds and packaged startup gate.
3. Walking Skeleton: authored action, state, UI and manual save/load.
4. Simulation Spine: time, restorable RNG, IDs, commands and state fingerprints.
5. Persistence & Developer Tools: quiet inspection, recovery and hands-off delivery.
6. OS framing proof: static blockout, selection and docked Operations (PR #12).

## Phase 6A: Workspace geometry and layout memory

Implemented by PR #14: four bounded resizable/collapsible rails, one geometry
owner, independent logical rail preferences, cancellation, keyboard/click controls
and deliberate available-size/GUI-scale behavior. ADR 0011 specifies support.
Reference remains 2560x1440, 20-unit rail edits and protected 1440x800 city space
at reference; smaller-window policy does not shrink all text below 100 percent.

## Phase 6B: Widget manipulation and responsive forms — CURRENT IMPLEMENTATION

This revision adds Work Scan and Recent Activity as movable bottom/right widgets.
Stable IDs, strict placements, semantic forms, local ordered packing, pointer
previews and rollback, keyboard transfer/resize and clickable menu alternatives
share one placement model. Committed widget preferences persist independently
using the same IO implementation as rail preferences. No game-save migration.

Preferred and effective forms are distinct. New placements need a fitting visible
destination; existing arrangements can compact and locally scroll when a host
shrinks. No rail auto-growth, permanent overlap, fabricated live data or rebuilding
all controls on updates. Candidate outlines describe reflow; actual component
relocation occurs at commit. See ADR 0012 and docs/state.md for limits.

The existing UI framework is now exercised with two real data sources. This is
not the final visual/product acceptance of Work Scan or the whole OS.

## Phase 6C: App lifecycle, selection and navigation — NEXT

- Stable embedded launcher, app-local Back and return-to-City semantics.
- Explicit rail-hosted and center-focus modes, not arbitrary overlapping windows.
- Restore city camera/selection after center-focus apps; preserve relevant app
  view, selection, scroll and focus without keeping unnecessary active work.
- Contextual deep links retain identity. Hidden views release active visual work
  and subscriptions without resetting simulation or persistent preferences.
- Demonstrate the lifecycle with existing functionality before adding new domains.

## Phase 6D: Reactive product components and integrated acceptance

- Fully author Work Scan's information hierarchy, forms and visual treatment.
- Coalesce updates and reconcile components by ID without losing user intent.
- Functional transitions, reduced motion and explicit empty/error/loading states.
- Isolated labeled fixtures cover states absent from current simulation.
- Demonstrate a second existing readout without forcing identical compositions.
- Exercise widget manipulation, app navigation, state updates, focus, layout
  restoration and save integrity together at supported sizes and GUI scales.
- Profile real update/manipulation cost rather than assert unmeasured performance.

### Exit to gameplay expansion

The integrated OS must rearrange/restore its workspace, keep widgets useful,
resume applications, respond without losing interaction state and preserve game
integrity. The owner accepts the actual direction and feel; engineering handles
repeatable regression testing and provides runnable builds. This does not require
every future app, gameplay domain, content tool or final art asset.

## Phase 7: First systemic vertical slice — BLOCKED BY PHASE 6 ACCEPTANCE

After UI acceptance, expand a city-connected opportunity through management,
consequences, persistence and replay using the established OS contracts. Narrow
state prerequisites for current UI are allowed; whole gameplay domains are not
required just to prove the workspace.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one at a time with ownership, APIs, tests, saves and diagnostics. Each integrates
with the established OS instead of creating an unrelated interface shell.

## Phase 9: Scale and production

Content tools, asset policy, save compatibility, measured profiling/soak tests
and durable releases follow actual scale. Reuse existing delivery workflows.

## Workflow

An approved slice authorizes routine implementation, branches, validation, fixes,
builds and eligible merges. Human input is for meaningful design and experiential
feedback, not test scripts or save repair. Each pass must improve a visible usable
capability without a speculative framework detour.
