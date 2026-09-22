# Functional Criminal OS: Prototype Research and Godot Direction

Research date: 2026-09-22
Scope: Desktop Crime Sim / Grit City, not the separate mobile crime project.
Status: Source findings plus engineering recommendations. Not implementation.
Priority decision: ADR 0010. Build order: docs/roadmap.md.

## 1. The correction

The OS is the player's operating environment for the game. A static framing of
panels around a map does not establish that product. The v0.0.6 Godot build is a
useful framing/integration proof; it is not an approved functional OS foundation.
Retain its simulation/save/build work and change the next implementation target.
UI-first means working manipulation, navigation, information and continuity,
not decorating a screenshot before returning to gameplay expansion.

## 2. Sources actually reviewed

Recovered from the owner's ChatGPT file Library:

- P1: UI_DECISION_MATRIX.md. Full file reviewed. SHA-256:
  4c4ba625df0a5aab8ab7c011ce3eb75db18def0700c3a17641310ea212667e1e
- P2: shell_manifest.json, Grit OS Shell epsilon-1. Full file reviewed.
- P3: Grit_City_0.68.12_Work_Scan_Product_Shell_I.html. Standalone source,
  26,480 physical lines, 9,830,373 bytes. SHA-256:
  3512a77e558e40118920bcc9b111fe920dab2feb3ac098e8b7f71d22899879e0
  Inspected relevant embedded modules, not every unrelated simulation module.
- G1: SIM-DURTY main at 98137a217c463311e14a4decedf977cd84bb3f28:
  roadmap/state, UI contract and criminal_os_shell.gd.

P3 contains an escaped worker bundle and older renderer helpers alongside current
paths. Finding a function or CSS class is not proof it is currently rendered.
Browser navigation to the recovered prototype was blocked by the execution
environment. This review is source-based; no fresh interactive browser playtest
or browser performance measurement is claimed. The larger engineering bible
referenced by P1 was not recovered. P3 is the reviewed version, not a claim that
no later prototype exists.

## 3. Recovered product rules

P1 describes four connected rails: full-height left/right, top/bottom between
them, with the city in the center. Reference canvas 2560x1440; design grid 32x18
at 80 units; rail adjustment in 20-unit steps; city minimum 1440x800 at that
reference. Content minima and shell minima are different constraints. A single
geometry owner must account for seams and gutters rather than assigning the
same full space independently to multiple regions.

The upper-left embedded L-shaped app tray is a signature. Bottom and right are
continuous workbench/instrument regions, not unrelated card stacks. Sparse
operational text, semantic linework, restrained materials and readable hierarchy
matter more than extra borders, glow or pseudo-radar. P1 explicitly places OS,
app flow, widget framework, interaction and visual approval before gameplay.

P1 supports both center-region apps and rail apps. Home/City returns to the city;
Back navigates within the active app. Apps resume state and accept contextual
deep links. This is not a mandate for floating overlapping desktop windows, and
not a mandate to squeeze every app into the same right-hand column.

Widgets have authored compact/wide/tall/major compositions. Size changes useful
information depth, not a uniform scale transform. Compact remains useful, not
an empty icon or unreadable miniature. Widgets summarize; apps manage.

## 4. What the prototype code implements

### Widget layout and manipulation

P3 src/widgets/layout-model.ts (physical lines 22323 onward) keeps pure logical
placement/form operations separate from DOM placement. moveWidget and resizeWidget
build candidates, verify allowed regions/forms and capacity, and reject invalid
results. Ordering has a stable ID tie-break. Capacity fitting selects smaller
authored forms deterministically with bounded iteration. No pixel coordinates
are serialized by this model.

src/widgets/manifest.ts (22573 onward) explicitly identifies forms as semantic
compositions and spans as primary-axis footprints. The reviewed implementation
packs bottom/right regions. This is narrower than the four-rail shell design;
do not claim four-rail arbitrary packing already exists in the HTML.

WidgetWorkspace (24989 onward) uses distinct drag/resize sessions, an interaction
arbiter, pointer/keyboard handlers, cancellation, and layout storage. Resize
cancellation restores original layout. Keyboard affordances include reorder and
rail transfer. Preserve these behaviors rather than copying the entire bundle.

### App lifetime and routes

AppRouter (14029 onward) separates route/navigation model from view owners. It
has start/stop, activation/suspension/disposal, local Back, return-to-City,
remembered views and route listeners. Center app presentation changes without
turning every navigation action into a fresh game session.

### Reactive widget ownership

WidgetFramework (24464 onward) matches geometry and surface definitions once,
uses explicit lifecycle owners, subscribes to declared read models, invalidates
registered render regions, and disposes subscriptions/renderers. This is more
substantial than a panel with labels updated by an unrelated button.

### Current Work Scan path and a porting hazard

The current idle path (22785 onward) produces a product-style opportunity list
with selected identity, take, travel, risk and an empty state. Rows carry stable
definition IDs and dispatch an Operations-focus event. Active presentation uses
phase-specific state. Older scan-field/radar helpers remain in the source; their
presence is not a design instruction to recreate decorative radar.

The renderer's #render (22719 onward) calls replaceChildren before rebuilding.
Source inspection therefore reveals a continuity risk for focus/scroll/hover on
updates. This is not a measured runtime bug report. The Godot implementation
should preserve keyed components and update changed values instead of porting
that rebuild strategy blindly.

## 5. External primary references and bounded lessons

E1. Godot Containers:
https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html
Containers own child positioning; manual changes can be overridden. Custom
Containers support authored layout. Proposal: a logical outer layout solver and
custom region Container, with ordinary Containers inside each widget.

E2. Godot Control/input:
https://docs.godotengine.org/en/stable/classes/class_control.html
https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
GUI consumption, focus and wheel propagation must be deliberate. Proposal:
UI owns its pointer region and active manipulation; city interaction receives
only applicable unconsumed input. Verify APIs against the pinned engine.

E3. Godot resolutions:
https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
The documentation distinguishes stretch behavior, UI scale and minimum window
size. Proposal: retain the reference design but define actual supported content
sizes and GUI scaling. A second scaled screenshot is not proof of reflow.

E4. Qt workspace design:
https://doc.qt.io/qt-6/qmainwindow.html
https://doc.qt.io/qt-6/qdockwidget.html
Central content, dock constraints, explicit corners, stable identities and
versioned workspace restoration are useful precedents. Borrow contracts, not Qt
as a new dependency or its default floating-window look.

E5. GridStack interaction:
https://gridstackjs.com/doc/html/classes/GridStack.html
https://gridstackjs.com/demo/column.html
https://gridstackjs.com/demo/two.html
Useful references for explicit movement/resizing, layout policies, serialization
and cross-region interaction. Not a recommendation to embed a browser in Godot.

E6. Apple widget design:
https://developer.apple.com/videos/play/wwdc2020/10103/
The published session overview emphasizes timely, glanceable information and
content/sizing/typography. Borrow information discipline, not platform-specific
refresh restrictions or a universal rounded-square appearance.

E7. W3C interaction guidance:
https://www.w3.org/WAI/ARIA/apg/patterns/windowsplitter/
https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html
Use keyboard-operable region resizing and non-drag pointer alternatives. Keyboard
support alone does not meet the separate non-drag pointer goal. These are design
references, not a claim of native-game WCAG or assistive-technology conformance.

## 6. Proposed Godot implementation contracts

These mechanisms are recommendations, not already shipped functionality.

### Three kinds of state

Gameplay authority remains in the existing session. Persistent presentation
preferences own rail sizes, widget identity/order/form and chosen layout. Local
view state owns route, selection, focus, scroll, hover and animation progress.
Do not include presentation rearrangement in gameplay RNG or simulation hashes.

### One geometry decision

A small layout model and solver produce valid region/widget rectangles from
reference rules, viewport, GUI scale, content minima and placement preferences.
Custom region Containers apply those rectangles. Widget interiors use normal
Containers/Theme resources. A temporary drag proxy is separate from managed
children so direct manipulation does not fight container layout.

Start with predictable ordered rail packing recovered from P3. Do not build an
unrestricted two-dimensional docking framework unless an approved use case needs
it. All four rails remain explicit shell regions; a manifest states which
widgets/forms may occupy each. No hidden automatic rail enlargement for a drop.

### Preview is not commitment

A drag/resize session has the original layout, current candidate and validity.
Pointer movement previews a result. Drop commits one valid result; Escape,
focus loss or cancellation restores the original. If the viewport changes
mid-manipulation, cancel or revalidate through one explicit policy. Never save
half-finished positions or let a dropped widget execute the control underneath.
Use the same solver for drag, keyboard and click-menu actions.

### Preferred versus effective layout

Preserve the user's chosen logical layout separately from the fit required by
the present window. A temporarily narrow window should not permanently erase a
larger layout. Persist committed UI preferences independently of manual gameplay
saving, associate the profile with the game slot, and provide reset-layout-only.
A missing widget, invalid profile or storage failure must have a bounded,
non-destructive fallback without resetting the simulation.

### App continuity

Use one region router and one selection model, not singleton managers for every
panel. Each app declares host mode and supported views. Navigation restores
app-local selection, tab, scroll and focus as appropriate. A center-focus app
owns the center input; returning restores the city's camera/selection. Hidden
views stop active visual work while simulation ownership remains unchanged.

### Reactive information, stable interaction

Read-model changes mark only affected components dirty. Coalesce updates and
reconcile by stable IDs instead of rebuilding the shell. Preserve focused rows,
scroll positions and pointer intent. Queue disruptive list reordering while a
row is actively manipulated/focused, then reconcile predictably. A changing
payout must not move the button the player is about to click.

P1's 'data changes state, not geometry' and the later continuous-information
idea need an explicit distinction: keep outer workspace geometry stable during
ordinary data changes; allow internal chart marks, comparisons and status
transitions to encode real changing data. This is a proposed interpretation,
not a claim the older documents spell out that distinction.

Separate simulation time from presentation motion. Animation may interpolate a
confirmed value but cannot invent authoritative progress. Honor reduced motion.
No fabricated history, decorative pulses or arbitrary radar marks replace data.

### Concrete widget contract

A widget definition needs a stable ID, allowed regions/forms, per-form minima,
read-model inputs, selection/deep-link actions, update policy and lifetime.
Its content component owns information hierarchy; the chassis owns placement,
resize handles and focus treatment. Reuse those contracts without forcing money,
work and people into identical label-number-bar compositions.

Work Scan should prove compact summary, wide comparison, tall list and major
progressive detail using existing state or clearly isolated lab fixtures.
An Operations handoff must carry identity rather than duplicate the whole app.

## 7. Acceptance as product engineering

Reuse current health, Windows delivery and render workflows. Add real mouse/key
input dispatch tests in addition to direct button-signal tests. Check canceled
moves, invalid drops, viewport changes during drag, region-wheel isolation,
focus restoration, semantic forms, saved layouts, missing definitions and
repeated open/close without growing listeners or retained nodes.

Capture multiple actual available sizes, including narrower/shorter windows,
with longer text, changed values, empty/error states and expanded content. Check
readability, minimum city space, focus visibility, clipping and pointer targets,
not just whether all rectangles remain on screen. Profile update and manipulation
cost against real component counts; no unmeasured performance promise is made.

Keep simulation/save checks running during UI work. Fixtures live in isolated
test/lab contexts, never masquerade as production systems. The owner judges
visual direction and interaction feel; automation handles repeatable regression.

## 8. Delivery boundary

Roadmap Phase 6 now covers workspace/layout memory, widget manipulation/forms,
app continuity and reactive product components before gameplay expansion. Each
pass must visibly improve the usable OS. No requirement to finish all future
apps or all final art before new gameplay. No new runtime, schema, engine or
workflow is introduced by this research/documentation correction.
