# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2, unchanged
Language: typed GDScript
Game version: 0.0.8
Reference design: 2560x1440

## Current milestone: Functional Criminal OS, Phase 6B

This revision implements widget manipulation and responsive forms on the Phase 6A
workspace. Actual acceptance and merge status belong to the matching PR and
exact-revision CI evidence. It does not complete or imply owner acceptance of
the full OS phase. Gameplay expansion remains blocked by ADR 0010.

## Implemented

The existing four rails, protected city geometry, manual game saves, recovery,
clock/RNG/ordered commands, build identity and preview pipeline remain.

- Work Scan and Recent Activity are movable data-backed widgets in bottom/right
  docks, with stable identity and explicit compact/wide/tall/major form contracts.
- Pure ordered packing separates preferred placement from current effective fit.
  New moves/resizes must fit the visible destination; they never grow rails.
- Pointer drag/resize has candidate outlines, destination/form or invalid feedback,
  commit on release and cancellation. Neighbors' proposed rectangles are outlined;
  their actual mounted views move only on commit, not during the preview.
- Keyboard movement/transfer/form selection and clickable menu alternatives use
  the same solver. Unavailable sizes are skipped by keyboard or disabled in menus.
- Work Scan inspection retains the shared selected activity; only Operations
  executes work. Recent Activity uses existing bounded, unsaved local events.
- Views and controls are reused by ID, not rebuilt on every state update or move.
- Committed widget preferences auto-save separately from both rail preferences
  and gameplay, through the existing bounded/staged preference IO implementation.
- Reset layout resets rails and widget arrangement only, not game state or camera.
- Existing profiles/saves are not migrated or silently overwritten. A missing
  widget profile uses defaults; damaged/future/foreign profiles are preserved.
- Current debug reports include widget layout, manipulation and storage status.

## Ownership and files

WorkspaceLayout/WorkspaceContainer remain the rail geometry authority.
WidgetLayout owns pure widget placement/form validation and derived rectangles.
WidgetWorkspace coordinates input, preview and mounted widget views; WidgetDock
owns bounded scrolling and candidate footprints. WidgetView displays real inputs.
WorkspacePreferences owns both codecs' bounded disk operations, with explicit
rails/widgets format selection rather than a duplicate IO implementation.
OsPresentationState owns selection/route; CityBlockout owns its local camera.
SkeletonSession and SkeletonSave remain unchanged gameplay/save authorities.

Game slot: user://walking_skeleton/slot_v1.json, schema 2 with v1 reader.
Rail profile: existing per-slot hash filename, format sim-durty.workspace v1.
Widget profile: same per-slot stem with .widgets.json, format sim-durty.widgets v1.
UI profiles are excluded from gameplay saves, RNG and simulation hashes.

## Fit and support policy

Minimum supported window remains 1280x800 at 100 percent. Optional 125 percent
needs 1600x1000 or temporarily falls back without erasing preference. At the
2560x1440 reference, the protected city reservation remains 1440x800.

Later host shrinkage may compact existing widgets temporarily. If even readable
compact minima cannot fit, their dock scrolls locally rather than scaling text,
dropping widgets or changing preferred choices. A new move or explicit form
change cannot create overflow in its destination. Restore a larger host to regain
the preferred form. Four shell rails still exist; only bottom/right are widget
placement regions in 6B. No claim of unrestricted four-rail grid docking.

## Validation

All previous suites and packaged Windows tests remain. Widget tests add strict
layout/storage cases, stable components, real viewport pointer/key dispatch,
preview/cancel/commit, resize, keyboard transfer, menu actions, focus-loss
notification, wheel isolation and preferred/effective fit at multiple scales.
Menu callbacks and focus-loss notifications are exercised directly in tests;
this is not a physical-device or OS accessibility certification.

The existing Windows gate launches the packaged game's debug probe through its
normal application entry point, moves widgets and restores their exact preferences
in another process while checking unchanged gameplay state/save bytes.
The existing acceptance workflow retains actual rendered default, moved, major,
valid-preview and invalid-preview views, plus all earlier workspace captures.
Exact run artifacts report actual results. Source execution is in CI, not claimed
as a local engine run in this chat environment.

## Limits and next

The city is still a static blockout with one existing errand, no invented live
opportunities, simulated people or fake event history. Widget forms demonstrate
functional composition on limited existing data; full product/material polish
and richer reactive information remain 6D. No new engine, addon, Autoload, game
save schema or CI workflow. One writer per profile; no power-loss guarantee.
Physical mouse hardware, clipboard and Windows GPU testing remain separate.

Next: Phase 6C app lifecycle, selection and navigation. Gameplay expansion remains
blocked until the bounded functional OS is accepted. See ADR 0012 and
architecture/widgets.md for 6B maintenance and interaction rules.
