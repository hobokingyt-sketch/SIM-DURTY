# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2 stable, unchanged
Language: typed GDScript
Game version: 0.0.4
Reference viewport: 2560x1440

## Current milestone: Simulation Spine

This revision implements the slice below. Merge/test completion belongs to its
actual PR and exact-revision CI evidence, not a prospective checkbox here.

## Implemented

- Retains the Walking Skeleton errand, native UI, explicit Save/Load/reset and
  existing Windows artifact verification.
- Integer GameClock: one tick = one minute; no competing elapsed-time authority.
- Seeded SimulationRng with full state/draw-count restoration and an engine contract.
- Stable per-timeline event ID allocation and persisted next-ID cursor.
- Explicit monotonic command ordering; rejects duplicates, out-of-order commands,
  invalid payloads and reentrant mutations before consuming any state.
- Detached bounded diagnostic event journal, not a fake historical data set.
- Canonical authoritative-state SHA-256 fingerprint including authored work inputs.
- Schema 2 saving and schema 1 in-memory migration. Original path retained;
  explicit Save upgrades it and preserves the previous primary as .bak.
- Test surface adds Step 1 minute, Step 15 minutes and Test random draw, with
  seed/tick/command/hash readout. Random draws are diagnostics, not game rewards.
- Current debug report includes real simulation identity and full state hash.

## Validation contracts

Retain all previous infrastructure and Walking Skeleton cases. Add primitive
bounds, RNG serialization/continuation, command rejection, detached state,
reentrancy, bounded journals, 1000-command replay and mid-replay restoration,
v1-to-v2 disk migration, and UI full-spine Save/Load checks.

The existing two-process packaged Windows probe also verifies full saved-state
hash and next random draw/work continuation. Linux acceptance captures the real
updated UI at 2560x1440 and 1600x900. Read the matching runs for actual results.

## Limits and compatibility

Time is command-driven. No live/automatic clock driver, offline progress,
per-tick world scheduler, city/crew/pressure or expanded economy is added.
The 500-cent payout and 15-minute errand remain test values.

Save format: sim-durty.walking-skeleton, schema 2; reads schema 1.
Slot: user://walking_skeleton/slot_v1.json (legacy filename, not schema authority).
Migration seed: 184726; old saves had no seed to recover. No history is invented.
Autoloads: none. External Godot addons: none.
RNG continuation is bound to the saved engine contract. Engine upgrades require
an explicit compatibility decision. No global-UUID guarantee, full event sourcing,
backup recovery UI, power-loss durability or concurrent-writer locking is claimed.

## Next milestone

Persistence & Developer Tools: recovery of retained backups, save inspection,
scenario tooling and clearer developer controls, before the OS + City Skeleton.
Preserve the manual-save contract and avoid adding gameplay systems out of order.

See ADR 0007 and docs/architecture/state_ownership.md.
