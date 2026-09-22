# ADR 0007: Command-driven simulation spine

Status: Accepted for the approved Simulation Spine slice
Date: 2026-09-22

## Scope

Extend the proven Walking Skeleton, not the full city simulation. Errands still
pay 500 integer cents and cost 15 integer minutes. No random payout is introduced.

## Authority and ordering

SkeletonSession remains the composition/transaction owner for this small domain.
GameClock owns an integer tick; one tick equals one minute. elapsed_minutes is a
compatibility read-model field derived from that clock, not another clock.

Commands are explicit dictionaries with sequence, type and amount. The next exact
sequence is accepted synchronously; stale, duplicate, skipped, malformed, unknown
and reentrant commands are rejected without consuming time, randomness or IDs.
There is no speculative asynchronous command queue or global event bus.

IdFactory allocates stable event IDs in one saved timeline. Reset/load rewind the
timeline deliberately; these are not globally unique UUIDs. One accepted command
allocates one event ID. A bounded 32-record diagnostic journal is detached from
callers. It is not persistent gameplay history or an event-sourcing store.

## Time

Time moves only through an accepted work command or an explicit bounded advance.
There is no wall-clock/frame authority, autonomous city loop, offline catch-up,
per-tick world scheduler, or fabricated continuous progress. These can be added
when a real system needs them. Manual steps preserve the current pacing contract.

## Randomness

SimulationRng wraps Godot RandomNumberGenerator, seeded explicitly with 184726 by
default. It saves seed, full internal state and draw count. The signed 64-bit RNG
state is canonical decimal TEXT, never a lossy JSON number. Seed is restored before
state. Engine/contract mismatches reject rather than silently reseed.

The wrapper is version-bound, not a claim of cross-engine-version determinism.
Godot documents the RNG algorithm as an implementation detail and says setting
seed changes state: https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html

An explicit rng_probe command and temporary test button exercise continuation;
the resulting number is diagnostic only and never changes money or game outcomes.

## Save compatibility

Schema 2 extends the existing format with the spine. The established slot_v1.json
PATH stays unchanged so old progress is found. Schema 1 is migrated in memory:
retain cash/minutes/completed actions; initialize the documented default unused
RNG and counters above completed actions; invent no past event records. The file
is not rewritten until explicit Save, which preserves the previous primary as .bak.

The state-only writer overload is for legacy fixture compatibility. Runtime saves
must pass BOTH session.snapshot() and session.spine_snapshot(). Main does so and
UI/disk/process tests cover this boundary. Future persistent domains should use a
single required checkpoint API rather than extending the compatibility overload.

Existing corruption/newer-version protection and staged write/readback remain.
No new claims of power-loss durability, simultaneous-writer locking or automatic
backup recovery are made. One game instance should write the slot.

## Replay and fingerprint

The canonical SHA-256 fingerprint includes normalized authoritative state,
clock/RNG/ID/command cursors, last diagnostic draw and authored work inputs. It
excludes build timestamps, screen state and the transient journal. It is a state
identity, not authentication, anti-cheat, or a hash of all past history.

Guarantee tested: same source/engine contract, initial checkpoint, authored data
and ordered commands produce the same checkpoint and bounded event suffix. A
1000-command test resumes halfway from serialized state. Packaged Windows probes
save in one process, reload in another, then verify the next RNG draw and work
command against a continuation oracle from the first process.
