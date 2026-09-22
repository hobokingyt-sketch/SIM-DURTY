# Roadmap

## Governing priority: functional UI first

The Criminal OS is a core game system. Gameplay expansion remains blocked by
ADR 0010 until the bounded functional OS is accepted.

The visual target is now explicitly locked by ADR 0014 and
`docs/design/visual_north_star.md`. Phase 6D is therefore a product-design and
reactive-engineering phase, not a vague “polish” pass.

## Implemented foundation

0. Foundation 0: typed Godot repository and health checks.
1. Infrastructure 1: project memory and architecture rules.
2. Infrastructure 2: traceable Windows previews and packaged startup gate.
3. Walking Skeleton: action -> state -> UI -> manual save/load.
4. Simulation Spine: deterministic time/RNG/IDs/commands and fingerprints.
5. Persistence & Developer Tools: inspection, recovery and hands-off delivery.
6A. Four-rail workspace geometry and independent layout memory (PR #14).
6B. Movable widgets, deterministic packing and semantic forms (PR #15).
6C. Center/rail app lifecycle, remembered navigation and continuity (PR #16).

## Phase 6D: Reactive Product UI + Locked Visual System — CURRENT

### 6D.1 — Material foundation — COMPLETE

Build the shared charcoal material kit before styling individual screens.

Deliver:
- new charcoal/graphite palette tokens,
- subtle diffused surface texture system,
- shared depth levels: chassis / surface / well / raised / active,
- one reusable method for material application,
- reference captures proving the texture remains subtle at 2560×1440 and the
  1280×800 supported minimum.

Do not yet redesign every component. The implementation uses one shared low-contrast shader-backed material on chassis, rails, app wells and widget bodies while leaving interaction geometry unchanged.

### 6D.2 — Engineered frame system — COMPLETE

Translate the concept's strongest signature into reusable primitives.

Deliver:
- layered shell/app/widget/control frame grammar,
- dark outer edge + graphite structure + inner highlight,
- chamfered/clipped corner treatment,
- structural seams/notches only where boundaries/affordances justify them,
- scalable implementation that does not distort when rails/widgets resize,
- no border proliferation around individual values.

This pass should make the OS read as a connected machine before fine detail. The implementation uses generated nine-patch frame textures so chamfers and border layers survive rail/widget resizing, plus non-interactive seam overlays for restrained structural ticks.

### 6D.3 — Control and icon kit — COMPLETE

Polish reusable interaction assets:
- launcher plates,
- ordinary buttons,
- primary action,
- tabs,
- fold/back controls,
- widget move/resize/menu handles,
- focus states,
- disabled states,
- selected/active states,
- consistent outlined icon treatment.

Interaction states change material seating and edge hierarchy rather than adding neon glow. The implementation uses authored control roles for standard, primary, tab, launcher, navigation, compact, handle and fold controls, plus one outlined SVG icon family for launcher and manipulation/navigation symbols.

### Visual Refinement R1 — Panel & Inset Depth — CURRENT IMPLEMENTATION

Refine only the surfaces that already exist. Do not change shell structure,
rail geometry, app hosting, widget placement, content hierarchy or feature set.

Deliver:
- clearer chassis → rail → inset well → raised module depth hierarchy,
- darker app/context/workbench wells,
- widgets reading as modules seated above their bays,
- soft edge light/shadow falloff rather than new decorative outlines,
- identical 6A–6C geometry and widget fitting before/after the pass.

### Visual Refinement R2 — Border & Shape Craft — NEXT

Refine existing frame construction only:
- border thickness consistency,
- chamfer proportion,
- outer-vs-inner edge hierarchy,
- corner joins,
- structural transitions between existing surfaces.

No decorative lines, bolts or invented detail.

### Visual Refinement R3 — Button & Control Craft

Refine the existing control kit's physical construction without changing its
roles or placement: chassis/face depth, selected seating, primary-action brass
economy, launcher engagement and tab integration.

### Visual Refinement R4 — Unified Visual Calibration

Compare the whole existing screen against the locked reference and normalize
material brightness, recess depth, border strength, accent economy, icon
brightness and surface consistency. No new interface structure.

### 6D.4 — Typography, spacing and information rhythm — AFTER R4

Apply the concept's visual hierarchy:
- large app/task titles,
- medium region titles,
- small uppercase system labels,
- restrained warm numeric emphasis,
- clean body copy and stable numerals,
- unified spacing/baseline system,
- remove temporary explanatory text that the UI no longer needs.

Test real text at reference and minimum supported sizes.

### 6D.5 — Work Scan product pass

Work Scan becomes the first fully authored premium widget.

Each semantic form must have genuinely different useful composition:
- Compact: immediate opportunity + key terms + action.
- Wide: comparison/readability across workbench width.
- Tall: scannable list/deeper state.
- Major: selected context and richer decision support without duplicating
  Operations.

Add:
- keyed/stable row identity,
- reactive value updates without component rebuild,
- explicit empty/unavailable/error/loading fixtures,
- pointer/focus/scroll preservation during changes,
- restrained state transition treatment.

No fake live opportunities or invented history.

### 6D.6 — Second-surface proof

Apply the same material/reactive system to a substantially different existing
surface: Session Record and/or Operations.

Goal: prove the design system is reusable **without making every system look like
the same card**.

Retain center-focus versus rail-hosted anatomy from 6C.

### 6D.7 — Motion and continuity

Add the motion grammar only after static material/hierarchy is correct:
- hover/press/select,
- widget reflow/form changes,
- app enter/return,
- value changes,
- attention states.

Implement reduced-motion behavior. Motion never becomes simulation authority.

### 6D.8 — Integrated OS acceptance

Run the real combination:
- rail resize/collapse,
- widget drag/resize/reflow,
- app navigation/Back/Home/deep links,
- state updates while views remain mounted,
- focus/scroll/pointer-intent preservation,
- profile restoration,
- save integrity,
- supported window sizes and 125% interface preference,
- visual captures against the locked north star,
- measured update/manipulation performance.

### Phase 6 exit

Exit only when:
1. 6A–6C functional contracts remain intact,
2. 6D material language is coherent across shell/widgets/apps,
3. Work Scan and a second surface prove reactive product quality,
4. no critical clipping/legibility/state-continuity defects remain,
5. automated regression/build gates are green,
6. **the project owner accepts the actual UI direction and feel.**

This does not require every future app or final game content.

## Phase 7: First systemic vertical slice — BLOCKED BY PHASE 6 ACCEPTANCE

After UI acceptance, expand a city-connected opportunity through management,
consequences, persistence and deterministic replay using the established OS.

## Phase 8: Simulation expansion

People/crew, economy, pressure, relationships, neighborhoods and property enter
one at a time with explicit ownership, APIs, tests and persistence.

## Phase 9: Scale and production

Content tools, asset policy, compatibility, measured profiling/soak tests and
release packaging follow actual scale.

## Workflow

Approved slices authorize engineering to handle implementation, validation,
fixes, builds and eligible merges. Human input is for meaningful product
judgment, not routine testing or code operations.
