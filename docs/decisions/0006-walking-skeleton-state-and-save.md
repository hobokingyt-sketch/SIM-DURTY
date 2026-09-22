# ADR 0006: Walking Skeleton State and Persistence

Status: Accepted
Date: 2026-09-22

## Scope

The owner approved one tiny end-to-end loop, not the full game. This slice adds
one placeholder errand and one local save slot. Its payout, initial cash, and
duration are engineering test values, not accepted economy balance.

## Decisions

- SkeletonWorkDefinition is authored data: stable activity ID, name, payout in
  integer cents, duration in integer minutes. The .tres contains $5 / 15 minutes.
- SkeletonSession alone owns cash_cents, elapsed_minutes, completed_actions.
  It starts at $10 / 0 / 0 and copies its command definition on construction.
- One explicit command validates all bounds, mutates all three fields, then emits
  one change signal. Snapshots are detached data, not writable shared state.
- Time advances only on actions. There is no running clock, RNG, tick, offline
  progress, operation lifecycle, economy, or city simulation yet.
- Main is the composition root: it connects view intent, session commands, and
  a small feature-owned save adapter. The view never mutates session internals.
- SkeletonSave owns the schema-one envelope and disk boundary. It does not live
  in core because the schema is deliberately specific to this vertical slice.
- The format ID is sim-durty.walking-skeleton; activity_id is skeleton_errand.
  The normal slot is user://walking_skeleton/slot_v1.json, outside the install.
- Decode checks format, version, activity, exact state fields, finite integral
  values and explicit bounds before restoring any live state. JSON floats are
  normalized only after validation. Booleans/strings/fractions are not integers.
- Save stages and flushes a same-directory file, reads it back, backs up the
  previous valid primary, and renames the staged file into place. It refuses to
  overwrite an unreadable/corrupt/newer-format primary. Backup rotation and
  replacement errors are surfaced. This is not a claim of power-loss durability
  or multi-process locking; only one game instance should write the slot.
- Load failure never changes the current session. Missing/corrupt/future files
  are distinct outcomes. Files are not silently deleted, migrated, or reset.
- Reset changes the live session only. Save is explicit. Startup loads an existing
  primary automatically. No autosave on quit. Backup recovery UI is not included.
- The first v1 fixture ships with this slice. Any later incompatible save change
  requires an explicit migration or documented compatibility decision.

## Acceptance

Unit and UI integration tests exercise the real command and button-signal paths.
Packaged Windows acceptance launches two separate EXE processes, saving in the
first and reloading in the second. Probes use a separate CI-only slot and run
only in debug builds. Native rendered screenshots are captured on Linux at
2560x1440 and 1600x900; they are not Windows graphical/input certification.

## Sources consulted

- https://docs.godotengine.org/en/stable/classes/class_json.html
- https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
- https://docs.godotengine.org/en/stable/classes/class_diraccess.html
