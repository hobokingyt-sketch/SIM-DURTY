# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2 stable, unchanged
Language: typed GDScript
Game version: 0.0.6
Reference viewport: 2560x1440

## Current milestone: OS + City Skeleton

This revision implements the bounded Phase 6 shell. Acceptance/merge status
belongs to matching PR and exact-source CI evidence, not a prospective checkbox.

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
Main composes the existing session/save adapter and the new presentation.
OsPresentationState owns selected activity/app and glance visibility;
CityBlockout owns its camera. Both are session-local, outside save/state hashes.
SkeletonView is a small compatibility seam, not a duplicate running interface.

Same slot: user://walking_skeleton/slot_v1.json. Format sim-durty.walking-skeleton,
schema 2 with schema 1 read migration. No save copying or new schema is required.
Autoloads: none. External Godot addons: none. Additional CI workflows: none.

## Validation

Keep all previous assertions. Add OS selection, command isolation, application
lifecycle, camera bounds/retention, drawer and update/record tests. Existing
Windows delivery additionally runs the packaged OS navigation probe. Existing
Linux acceptance captures normal city, Operations and developer drawer at both
reference sizes. Exact run evidence reports what passed.

## Limits

This is an authored static city blockout, not a living world simulation. There
are no citizens, businesses, crew, pressure, travel cost, offline progress or
new economy here. The fixed errand remains a test fixture.

Rails are authored regions in this pass. Rail resizing, arbitrary widget dragging,
grid reflow and persistent UI layouts are not implemented. UI/camera survive
navigation, not restarts. Records are local journal entries, not saved history.
The existing single-writer and no-power-loss-durability limitations still apply.
Physical mouse, clipboard and Windows GPU testing are separate from headless CI.

## Next milestone

First systemic vertical slice: make an actual city-connected opportunity produce
meaningful cross-system consequences, adding only the required domain owners.
Do not turn this shell phase into another infrastructure framework.
See ADR 0009 for the interaction boundary and deferred layout features.
