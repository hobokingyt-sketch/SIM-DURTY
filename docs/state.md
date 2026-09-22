# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2 stable, unchanged
Language: typed GDScript
Game version: 0.0.6
Reference viewport: 2560x1440

## Current milestone: Functional Criminal OS — REOPENED

PR #12 implements a bounded OS framing proof. It is NOT acceptance of the final
OS interaction/visual architecture. On 2026-09-22 the owner reaffirmed UI-first
functional development. ADR 0010 and the revised roadmap supersede the previous
immediate move to gameplay expansion. This correction changes documentation only.

## Implemented

The existing owned session, command-driven clock, seeded RNG continuation,
stable IDs, manual saves, schema 2/v1 reader, recovery and debug report remain.
No simulation or persistence rules are changed.

- Native OS framing: top navigation/time, left glance widgets, central city,
  right context/Operations and bottom status/storage with optional drawers.
- Shared typography/surface/spacing Theme through OsTokens.
- Work Scan reads the existing activity. It selects work but does not execute it.
- One labeled city blockout and one native selectable marker for that activity.
- One presentation selection owner shared by marker, widget and context.
- Operations executes the existing command in an authored dock beside the city.
- Closing/reopening Operations retains city camera and selected work.
- Bounded pan/zoom, reset framing and a collapsible glance region.
- Routine updates versus attention/recovery; real bounded journal records only.
- Developer instrumentation remains hidden by default; recovery stays contextual.
- Debug reports add current presentation route and camera, not local file paths.

## Compatibility and ownership

SkeletonSession remains the sole gameplay authority. SkeletonSave is unchanged.
Main composes the existing session/save adapter and the presentation.
OsPresentationState owns selected activity/app and glance visibility;
CityBlockout owns its camera. Both are session-local, outside save/state hashes.
SkeletonView is a small compatibility seam, not a duplicate running interface.

Same slot: user://walking_skeleton/slot_v1.json. Format sim-durty.walking-skeleton,
schema 2 with schema 1 read migration. No save copying or new schema is required.
Autoloads: none. External Godot addons: none. Additional CI workflows: none.

## Existing validation

PR #12 retained previous assertions and added selection, command isolation,
camera bounds/retention, drawer and update/record checks. Packaged Windows
navigation and Linux reference captures were verified for that revision.
Those checks do not establish drag/resize, full app lifecycle, layout persistence,
accessibility or final product quality that the implementation does not provide.

## Limits

This remains a static city blockout, not a living world simulation. There are no
citizens, businesses, crew, pressure, travel cost, offline progress or new economy.
The fixed errand remains a test fixture.

Rail resizing, movable widget packing, responsive widget forms, full multi-app
navigation and persistent UI layouts are NOT implemented. They are now current
Phase 6 work, not optional polish deferred beyond gameplay expansion. UI/camera
currently survive navigation, not restarts. Records are local journal entries,
not saved history. Single-writer and no-power-loss-durability limits remain.
Physical mouse, clipboard and Windows GPU tests are separate from headless CI.

## Research completed in this documentation pass

Reviewed recovered desktop UI Decision Matrix, shell manifest and 0.68.12
standalone source: layout model, widget manifest/manipulation, app router,
lifecycle/read-model framework and Work Scan rendering. Compared relevant
Godot, Qt, GridStack, Apple and W3C primary guidance. Full source provenance,
implementation gaps and research limitations are in docs/design/ui_os_research.md.
No new UI implementation or Windows build is claimed by these documents.

## Next implementation

Phase 6A: Workspace geometry and layout memory. Follow with functional widget
manipulation, app lifecycle and reactive product components. Reuse current
simulation and delivery machinery. Phase 7 gameplay expansion is blocked until
the bounded functional OS acceptance described in docs/roadmap.md and ADR 0010.
