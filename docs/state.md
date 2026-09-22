# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2 stable, unchanged
Language: typed GDScript
Game version: 0.0.5
Reference viewport: 2560x1440

## Current milestone: Persistence & Developer Tools

This revision implements the bounded Phase 5 slice below. Acceptance and merge
status belong to the matching PR and exact-revision CI evidence.

## Implemented

Foundation 0, Infrastructure 1/2, Walking Skeleton and Simulation Spine remain
in place: owned integer state, fixed errand, explicit commands, controlled clock,
seeded continuation, stable per-timeline IDs, bounded journal, full fingerprint,
schema 2 with schema 1 migration and verified packaged Windows delivery.

This slice adds:
- Automatic read-only inspection of the current and backup save.
- One contextual recovery action only for a damaged/missing primary with a
  compatible, valid backup. No silent fallback from a newer/incompatible save.
- Staged recovery, exact backup preservation and a separate retained copy of
  the damaged original. Stale file changes stop recovery.
- Developer controls hidden by default; optional bounded storage/state/event
  inspector. No fake historical records or new simulation owners.
- Current storage/recovery details in Copy debug report.
- Recovery/migration/refusal/UI scenarios in the existing automated suite.
- Actual packaged Windows recovery followed by fresh-process auto-load and
  future RNG/work verification, using an isolated CI-only slot.
- Normal and expanded-tools reference captures through existing acceptance CI.
- Hands-off engineering handoff rules in root AGENTS.md.

## User workflow

Open the build, play, Save, and continue in the next build. Existing v1/v2 saves
are read without moving files. Manual saving remains intentional. Developer
tools are optional, not required for play or development approval. A recovery
action appears only when it is applicable and preserves prior files.

## Ownership and compatibility

SkeletonSave owns inspection and disk repair of the established slot.
Main owns orchestration and presentation cache. SkeletonSession still owns all
simulation state. The inspector reads detached state/journal snapshots.
Format: sim-durty.walking-skeleton; schema 2 (reads 1).
Slot: user://walking_skeleton/slot_v1.json, unchanged.
Autoloads: none. External Godot addons: none. New CI workflows: none.

## Limits

Still no automatic simulation scheduler, offline progress, city, crew, pressure
or expanded economy. The errand is still a fixture, not economy balance.
One process should write a slot. No multi-writer lock or power-loss durability
is promised. At most 32 rejected-original copies are retained without automatic
deletion. Oversized originals and incompatible formats require deliberate
engineering attention; they are not silently replaced.

## Next milestone

OS + City Skeleton. Phase 5 does not expand into another infrastructure framework.
Entity inspection and general content/scenario editors wait for real domains.
See ADR 0008 for recovery details and the hands-off development constraint.
