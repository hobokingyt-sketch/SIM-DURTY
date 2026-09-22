# Roadmap

## Governing priority: functional UI first

The Criminal OS is a core game system, not presentation polish to defer until
more simulation exists. The owner reaffirmed this on 2026-09-22. Phase 6 is
reopened. Gameplay-domain expansion waits for the functional OS acceptance below.
Read ADR 0010 and docs/design/ui_os_research.md before planning UI work.

The v0.0.6 shell remains a usable engineering baseline, NOT an approved final
OS design. Passing startup/state tests does not establish product acceptance.
No existing simulation, persistence or build infrastructure is discarded.

## Implemented baseline

0. Foundation 0: bootable typed-GDScript repository and health checks.
1. Infrastructure 1: project memory, scoped AGENTS and architecture rules.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: authored action -> state -> UI -> explicit save/load.
4. Simulation Spine: controlled time, seeded continuation, stable IDs, commands,
   bounded journal, fingerprints and compatible schema-2 persistence (PR #10).
5. Persistence & Developer Tools: quiet inspection, recovery and hands-off
   development contract (PR #11).
6. OS framing proof: static blockout, shared selection and docked Operations
   handoff (PR #12). Useful partial implementation; the UI phase remains open.

## Phase 6: Functional Criminal OS — CURRENT

Source basis: recovered desktop prototype and its UI Decision Matrix. This is
not the separate mobile crime project. Preserve interaction intent, not all
legacy code or abandoned styling. Source-derived rules and proposed engineering
mechanisms are distinguished in the research document.

### 6A — Workspace geometry and layout memory — NEXT IMPLEMENTATION

Deliver an operable shell rather than another static mockup:
- Four bounded, resizable/collapsible rail regions around the city.
- Reference geometry: 2560x1440, 32x18 design grid, 80-unit cells, 20-unit rail
  steps and 1440x800 minimum city region at the reference layout.
- One geometry owner accounts for seams, margins and content minima.
- Icon-first embedded launcher and restrained, continuous OS surfaces.
- Versioned logical UI preferences, kept separate from simulation state.
- Cancellation, reset-layout-only and input isolation work from the first pass.
- A smaller-window/GUI-scale policy that preserves legibility, not just a
  uniformly reduced reference screenshot. Record measured support limits.

### 6B — Widget manipulation and responsive forms

- Stable widget IDs, allowed regions, semantic forms and minimum sizes.
- Drag preview, deterministic local reflow, valid/invalid targets and rollback.
- Resize changes information composition rather than shrinking all text.
- Same placement rules for mouse, keyboard and a non-drag pointer alternative.
- Persist committed preferences, never partial drag positions.
- Prove bottom/right cross-rail behavior recovered from the prototype first;
  expand allowed regions explicitly. Four rails do not imply every widget can
  occupy every rail. Do not silently reduce the four-region design to two.

### 6C — App lifecycle, selection and navigation

- Persistent launcher, local app navigation, Back and return-to-City semantics.
- Explicit rail-hosted and center-focus app modes; no arbitrary overlapping
  desktop windows. Center-focus apps restore city camera/selection on return.
- Remember app view, selection, scroll and focus where relevant.
- Widget-to-app deep links retain the same selected entity/work identity.
- Hidden views release active work/subscriptions without resetting authority.

### 6D — Reactive product components and acceptance

- Work Scan is the first fully authored responsive widget, not a generic card.
- Real read models drive values and visual information; no fabricated live data.
- Coalesce updates and reconcile persistent components by ID. Preserve focus,
  scroll, hover and pointer intent during changing information.
- Functional transitions, reduced motion, empty/loading/error/unavailable cases.
- Isolated labeled fixtures exercise states absent from the current simulation.
- Apply the same component contract to a second existing readout to prove reuse.
- Exercise real input dispatch, cancellation, layout restoration, app switching,
  continuous updates and rendering together through existing automated gates.

These are visible capability slices, not prerequisites for a speculative general
framework. Combine adjacent work when coherent; do not invent extra bureaucracy.

### Exit to gameplay expansion

Exit only when the integrated OS can resize/rearrange/restore its workspace,
keep widgets useful at supported sizes, navigate and resume apps, react without
losing interaction state, and preserve simulation/save integrity. The owner must
accept the actual UI direction and interaction feel. Engineering runs regression
checks; the owner is not asked to operate test scripts or validate counters.

This does NOT require every future app, game domain or final art asset to exist.
It requires a credible functional OS pattern demonstrated end to end.

## Phase 7: First systemic vertical slice — BLOCKED BY PHASE 6 ACCEPTANCE

Only after UI acceptance, expand a city-connected opportunity through management,
consequences, persistence and replay. Reuse the established OS contracts. Narrow
state prerequisites needed to make current UI functional remain permitted;
entire new gameplay domains are not prerequisites for laying out the OS.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one domain at a time. Each has an owner, API, persistence, diagnostics and tests,
and integrates into the established OS rather than inventing a new UI shell.

## Phase 9: Scale and production

Content tools, asset policy, save compatibility, measured profiling/soak testing
and durable releases follow actual scale. Existing delivery gates are reused.

## Workflow

Engineering handles approved implementation, tests, fixes, builds and eligible
merges. Human feedback is for meaningful product choices and experience. Read
state.md for implemented capability; future entries here are not shipped features.
