# Project State

## Canonical project

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2 stable (unchanged)
Language: typed GDScript
Reference UI viewport: 2560x1440
Game version: 0.0.3

## Current milestone

**Walking Skeleton**

This revision implements the slice below. Completion/merge and test results must
be read from the matching PR and exact-revision CI runs, not inferred from this file.
Foundation 0 and Infrastructure 1/2 remain the underlying baseline.

## Implemented runtime

- One authored placeholder errand: +500 cents and +15 minutes per accepted action.
- One headless session owner: cash, elapsed minutes, completed actions.
- Fresh session: 1000 cents, zero elapsed minutes, zero completed actions.
- Native Godot test surface displaying real values, activity, Save, Load,
  Reset session, unsaved-state feedback, and a fresh Copy debug report.
- Explicit save slot with schema 1; startup loads a saved slot automatically.
- Reset changes only the live session. Unsaved changes are not saved on quit.
- Strict save validation, staged/read-back-checked replacement, previous-save
  backup, and preservation of corrupt/newer-format primary files.

## Validation implemented

- Retained infrastructure tests plus session, malformed data, bounds, disk
  roundtrip/replacement, v1 fixture, and UI integration tests.
- Two-process Windows EXE save/load acceptance before publishing the preview.
- Linux source/render acceptance at 2560x1440 and 1600x900.
- Isolated test/probe save locations, separate from the normal player slot.

## Limits

No live clock, RNG/seed, simulation tick, offline progress, city, crew, pressure,
real economy, or full Criminal OS. The screen is a test surface, not the final UI.
The payout/duration are test fixtures, not balance decisions.

The save slot is user://walking_skeleton/slot_v1.json. Backup recovery tools,
power-loss durability, file locking across concurrent game instances, and future
migrations are not implemented. Failed loads/writes report errors without silently
resetting the slot. Only one game instance should write to a slot.

## Identity

Save schema: 1 (sim-durty.walking-skeleton)
Simulation seed/tick: none; elapsed_minutes is real but is not a running clock.
Autoloads: none. External Godot addons: none.

## Next milestone

**Simulation Spine**: controlled clock, seeded RNG, stable IDs, and explicit
command ordering, added incrementally on top of this proven vertical path.

See ADR 0006 and docs/architecture/state_ownership.md. Tests and preview evidence
belong to the exact source SHA they exercised. Owner graphical/game-feel approval
remains distinct from automated engineering acceptance.
