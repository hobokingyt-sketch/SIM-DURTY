# ADR 0008: Quiet developer tools and explicit safe recovery

Status: Accepted for this slice
Date: 2026-09-22

## Context

The owner wants a mostly hands-off chat-to-game development pipeline, not a
sequence of technical chores. Existing simulation, schema migration, headless
probes and Windows delivery gates already cover most Phase 5 prerequisites.
The concrete missing capability is recovery of the retained previous save.

## Decision

Reuse SkeletonSave, schema 2, the established slot path and all existing gates.
Do not introduce an autosave policy, editor framework or additional CI workflow.

SkeletonSave owns read-only inspection and recovery of its primary/.bak pair.
Inspection runs at startup and storage/inspection actions, not per simulation tick.
A valid primary loads normally. Nothing silently overwrites a damaged primary or
rolls back newer/unsupported schema or RNG contracts. Missing/damaged primary
plus a valid bounded backup exposes one contextual Recover previous save action.
The action states that it replaces the live session. No routine modal is added.

Recovery revalidates the inspected content token, stages and validates an exact
backup copy, preserves damaged primary bytes under an unused rejected filename,
then promotes the staged copy. The backup is never consumed. File changes
invalidate stale recovery intent. Existing evidence is never overwritten; at
32 retained rejection copies recovery stops rather than deleting evidence.
Oversized originals beyond the existing 16 KiB save bound are not automatically
copied. Unsupported/newer formats are not treated as recoverable corruption.

A v1 backup is restored as exact v1 bytes; migration remains in memory until an
explicit Save. Current schema 2 continuation is unchanged. Normal Save refuses
a missing primary with a retained backup so it cannot hide a recovery situation.

Main composes storage with the session, and caches only presentation inspection
results. No simulation state ownership changes. Failed loads/recovery do not
reset the live session. Developer controls and read-only storage/event inspection
are collapsed by default in the existing surface, in a bounded scroll area.
Copy debug report includes current storage/recovery context and the existing
bounded local journal, never user filesystem paths or internal recovery tokens.

Scenario testing is automated: extend existing source acceptance and Windows
EXE probes with isolated corrupt-save recovery and fresh-process continuation.
The fixture cannot address the player slot. Retain all prior tests. Do not make
the owner execute the scenario or approve normal engineering steps.

## Boundaries

One writer per slot remains required. Digest rechecks are stale-intent checks,
not a multi-process filesystem lock. No fsync/power-loss guarantee, automatic
repair of oversized/unknown files, encryption, cloud sync or tamper-proof saves
is claimed. Normal user saves are not deliberately corrupted by the probe.
Manual saving and the fixed errand/command-driven clock remain unchanged.
Graphical captures are software-rendered Linux evidence, not Windows GPU or
physical-input certification.

## Phase exit

When exact-revision existing gates and the added recovery scenarios pass, move
to OS + City Skeleton. Entity inspectors and general scenario editors wait for
actual entities/use cases. The normal owner handoff is a runnable build and a
short description, not a technical test checklist.
