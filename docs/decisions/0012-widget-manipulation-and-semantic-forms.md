# ADR 0012: Widget Manipulation and Semantic Forms

Date: 2026-09-22
Status: Implementation decision for approved Phase 6B.
Validation and merge evidence: matching PR and exact-revision CI artifacts.
Depends on ADR 0010 (UI-first) and ADR 0011 (four-rail workspace).

## Scope

Prove bottom/right widget manipulation recovered from the desktop prototype.
Keep the four-rail shell, city reservation, existing commands, save schema and
manual gameplay saving. Do not create new domains just to populate the interface.
Use two real sources: existing work definition/session and bounded local events.
Full app lifecycle and final reactive/product acceptance remain 6C and 6D.

## Model and rendering

WidgetLayout is a small pure ordered packing model, not an unrestricted docking
framework. The registry declares two stable IDs and four supported semantic forms.
Only bottom/right accept these widgets. Bottom packs horizontally, right vertically,
with 12-unit gaps and deterministic fitting/tie ordering. Pixel rectangles are
derived, not serialized. Validation requires unique known IDs, supported regions,
forms and contiguous order values; JSON number types are normalized after validation.

Work Scan starts bottom/wide. Recent Activity starts right/tall. Compact/wide
show concise summary and action, tall uses vertical composition with more detail,
and major exposes additional state/events with greater space. These are limited
real-data forms, not a claim the final Work Scan design has been accepted.

WidgetDock applies solver rectangles to persistent Control children. Existing
widgets are reparented only on committed region changes. WidgetView retains its
controls, selection inputs and actual read-model values across moves/updates.
Ordinary internal Containers still own text/action layout.

## Manipulation contract

A header move or resize handle starts a transient gesture. A floating noninteractive
label follows the pointer; candidate outlines show the moved widget and local
neighbor placements. Actual widgets stay in their original positions until commit.
Preview is not an automatically persisted placement or live gameplay command.

Five logical units distinguish a move from a simple press. Release commits a
valid changed candidate once. Escape, right-click, focus loss, window/rail/host
geometry changes or relevant visibility/page changes cancel it. A canceled release
is consumed rather than activating the city/control beneath it. Outer rail and
widget gestures cannot start concurrently.

Resize chooses the nearest semantic form from the pointer delta, rather than
permitting every arbitrary pixel size. Arrow controls navigate fitting forms;
impossible intermediates are skipped. Enter on a move handle transfers regions.
Clickable menus offer region, order and size choices through the same model.
Unsupported destinations/forms are disabled or rejected, never forced.

## Preferred versus effective layout

Committed ID/region/order/form is a preference. The current viewport may need a
smaller effective form. Shrinking/restoring a window does not rewrite that choice.
Capacity fitting compacts deterministically. If a previously valid arrangement
cannot fit even at compact minima, a bounded dock scrolls without shrinking text,
discarding widgets or enlarging the rail. New moves or explicit form choices must
fit their visible destination and cannot create overflow. A cross-region move
commits the form actually shown by its valid preview; other preferred forms remain.

The existing 100/125-percent workspace transform is respected for pointer coordinates.
The 6A minimum window and city reservation policies are unchanged.

## Persistence

Avoid another save implementation or changing the already-shipped rail codec.
WorkspacePreferences gains a closed rails/widgets format selection, sharing bounded
read, validate, normalize, stage, readback and replace behavior. The existing
sim-durty.workspace version-one rail profile is unchanged.

Widget profile: sim-durty.widgets version one, same game-slot-derived filename
stem plus .widgets.json. It stores only preferred logical placement, not preview,
effective rectangles, hover, camera, events or game state. Only changed commits
write. Profile loading and fitting do not write. Missing profiles use defaults;
corrupt, future or foreign profiles are preserved with live fallback and reported
errors. Reset layout affects both UI preferences but never gameplay or camera.
No automatic repair, concurrent-writer or power-loss guarantee is added.

## Verification and delivery

Keep all existing suites/probes. Test pure validation/packing, file protection,
real viewport pointer/key dispatch, canceled and committed moves/resizes, menu
callbacks, focus-loss notification, wheel isolation, scale and stable component
identity. Capture actual views at supported dimensions. Distinguish injected
input/notifications from physical hardware or accessibility certification.

Packaged Windows tests enter the normal application with a debug-only custom
argument and isolated save/profile namespace. Do not rely on --script/path overrides
being supported by standard export templates. No weakening of export security or
extra runtime dependency is required. A separate process restores the exact widget
profile and checks unchanged game bytes/hash. Existing delivery publishes only
a candidate that passed the Windows gate. Retain exact source snapshot alongside
acceptance evidence to support inspection without assuming local clone access.
