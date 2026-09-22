# Roadmap

## Governing priority: functional UI first

The Criminal OS is a core game system, not presentation polish to defer until
more simulation exists. Phase 6 remains open under ADR 0010. Gameplay-domain
expansion waits for functional and visual OS acceptance. Read the recovered
desktop research in docs/design/ui_os_research.md; do not confuse it with the
separate mobile crime project or copy every legacy implementation choice.

Actual completion/merge evidence belongs to matching PRs and exact-revision CI.
Engineering acceptance does not substitute for owner acceptance of UI direction.

## Implemented foundation

0. Foundation 0: bootable typed-GDScript repository and health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture rules.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: authored action -> state -> UI -> manual save/load.
4. Simulation Spine: time, RNG continuation, IDs, commands, state fingerprints.
5. Persistence & Developer Tools: quiet inspection, recovery and hands-off delivery.
6. OS framing proof: static blockout, shared selection and docked Operations.
   PR #12 is a partial integration proof, not final OS product acceptance.

## Phase 6A: Workspace geometry and layout memory — CURRENT IMPLEMENTATION

This revision implements four bounded resizable/collapsible rails, one geometry
owner, independent versioned layout preferences, cancellation, keyboard and
non-drag pointer controls, and explicit available-size/GUI-scale behavior.
Reference design remains 2560x1440, 32x18 at 80 units, 20-unit rail steps and
1440x800 minimum city reservation at reference. Smaller-window policy is explicit
in ADR 0011, not accomplished by automatically shrinking all typography.

Source fields that existed before this slice remain authoritative: simulation,
game save schema and manual gameplay saving are unchanged. Layout is a separate
presentation preference, not an additional gameplay state owner.

Read docs/state.md, ADR 0011 and matching PR evidence for exact implementation
and validation. This does not claim widget dragging or final visual polish.

## Phase 6B: Widget manipulation and responsive forms — NEXT

- Stable IDs, allowed regions, authored compact/wide/tall/major forms and minima.
- Drag preview, deterministic local reflow, validity feedback and rollback.
- Resize changes useful information composition rather than shrinking text.
- Mouse, keyboard and non-drag actions use the same placement rules.
- Persist committed preferences only. No forced overlap or automatic rail growth.
- Prove recovered bottom/right cross-rail behavior first, with an explicit manifest;
  expand allowed regions deliberately without erasing the four-rail shell contract.

## Phase 6C: App lifecycle, selection and navigation

- Embedded launcher, local Back and return-to-City semantics.
- Rail-hosted and center-focus modes; no arbitrary overlapping desktop windows.
- Restore city camera/selection after center-focus apps; preserve app-local view,
  selection, scroll and focus where relevant.
- Contextual deep links retain identity. Hidden views release active visual work
  and subscriptions without resetting gameplay authority.

## Phase 6D: Reactive product components and integrated acceptance

- Work Scan is the first fully authored responsive product widget, not a generic card.
- Real read models drive updates; isolated labeled fixtures cover absent test states.
- Coalesce updates and reconcile by stable IDs without losing focus/scroll/pointer intent.
- State-driven transitions, reduced motion, empty/error/loading/unavailable cases.
- Demonstrate reuse with a second existing readout without forcing identical visuals.
- Run manipulation, input isolation, layout restoration, navigation and updates together.

### Exit to gameplay expansion

Exit when the integrated OS can resize/rearrange/restore its workspace, keep
widgets useful at supported sizes, resume apps, react without losing interaction
state, and preserve simulation/save integrity. The owner accepts actual direction
and feel; engineering runs routine regression checks and delivers runnable builds.
This does not require every future app, domain, content tool or final art asset.

## Phase 7: First systemic vertical slice — BLOCKED BY PHASE 6 ACCEPTANCE

After UI acceptance, expand a city-connected opportunity through management,
consequences, persistence and replay using the established OS. Narrow state
prerequisites for current functional UI are permitted; entire gameplay domains
are not prerequisites for designing the workspace.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one at a time with one owner, API, tests, persistence and diagnostics. Each uses
the established OS rather than inventing a new interface shell.

## Phase 9: Scale and production

Content tools, asset policy, save compatibility, measured profiling/soak testing
and durable releases follow actual scale. Reuse existing delivery gates.

## Workflow

For an approved slice, engineering handles branches, implementation, testing,
fixes, builds and eligible merges. The owner directs the product and gives
experiential feedback, not routine test-script or save-repair labor. Each UI
pass must visibly improve a usable capability; no speculative framework detours.
