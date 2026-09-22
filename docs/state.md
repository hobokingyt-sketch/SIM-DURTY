# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2, unchanged
Language: typed GDScript
Game version: 0.0.7
Reference design: 2560x1440

## Current milestone: Functional Criminal OS, Phase 6A

This revision implements workspace geometry and independent layout memory.
Actual acceptance/merge status comes from the matching PR and exact-revision
CI evidence. The whole functional OS phase is NOT complete after this slice.
Gameplay-domain expansion remains blocked under ADR 0010.

## Implemented

- Four native bounded rail regions with one layout owner, 20-unit resizing,
  collapse/expand and a city reservation. Full-height sides own the corners.
- Pointer previews, commit on release, cancellation and keyboard splitter input.
  The Layout workbench supplies non-drag pointer alternatives.
- Icon-first embedded launcher, continuous rail surfaces, bounded workbench pages
  and retained city/context/Operations behavior. No new simulation domain.
- Preferred layout separate from fit-to-current-window geometry.
- Version-one logical UI profiles associated with game slots in a separate
  namespace; auto-save committed layout changes only, restore without game edits.
- Reset layout only. Corrupt/future profiles are retained with a live fallback.
- Native-size 100-percent UI rather than a uniformly shrunk reference canvas;
  explicit optional 125-percent scale with a smaller-window fallback.
- Existing manual game Save/Load, schema-two/v1 reader, recovery, RNG continuation,
  deterministic state and build identity retained.

## Ownership

WorkspaceLayout owns preferred rails/scale and transient resize preview.
WorkspaceContainer owns application of solved geometry and manipulation routing.
WorkspacePreferences owns only independent profile IO. OsPresentationState owns
route/selection, CityBlockout its camera. UI state stays outside game hashes.
SkeletonSession and SkeletonSave remain gameplay/save authorities, unchanged.

## Support policy

Minimum window/content size: 1280x800 at 100 percent.
At 2560x1440/100 percent, minimum city viewport is 1440x800.
At smaller supported windows, the reservation scales explicitly with available
size, while text does not automatically shrink. 125 percent needs 1600x1000;
otherwise effective 100 percent is used without losing the preferred setting.
See ADR 0011 for exact geometry and failure behavior.

## Validation

Retain all earlier assertions and packaged Windows probes. Add layout validation,
all rail-collapse combinations over multiple sizes, preview/cancel/commit,
profile protection, actual viewport mouse/key dispatch and gameplay isolation.
The existing Windows gate also verifies fresh-process layout restoration.
Existing acceptance captures normal, layout, folded and enlarged workspaces.
Read matching evidence for actual pass/fail results. No local engine execution
is claimed: the active container has no Godot executable or network clone access.

## Compatibility and limits

Game slot and schema unchanged: user://walking_skeleton/slot_v1.json, schema 2,
with the schema 1 reader. Manual game saves remain manual. Layout profile changes
need no game save migration. No new Autoload, addon or CI workflow.

This is still a static city with one existing errand. Widget dragging/reflow and
semantic forms are Phase 6B, not implemented here. Full multi-app lifecycle,
final material/visual polish, saved camera/app state and automatic city simulation
are not claimed. Native input tests dispatch events; physical-device/Windows GPU
playtesting remains separate. One writer per profile/slot; no power-loss promise.

## Next

Phase 6B: Widget manipulation and responsive forms, using this workspace geometry.
Do not resume gameplay expansion until the bounded functional OS phase is accepted.
