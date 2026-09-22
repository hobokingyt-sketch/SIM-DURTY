# Roadmap

This roadmap controls **build order**, not product ambition. The master vision may describe systems years before they are implemented.

Each phase should make the next phase easier without speculatively building the whole game.

## Phase 0 — Foundation 0 — COMPLETE

Purpose: prove that the repository can boot, test, and validate a minimal Godot project.

Exit conditions:
- Godot version pinned.
- Typed GDScript baseline.
- Main scene boots.
- Automated tests run.
- GitHub Actions verified.
- Root engineering contract exists.

## Phase 1 — Infrastructure 1: Project Memory & Guardrails — CURRENT

Purpose: make long-running chat-to-game development recoverable and resistant to architectural drift.

Scope:
- canonical reading/recovery order,
- long-range master vision preserved separately from implementation state,
- accepted design canon,
- long-term roadmap,
- scoped engineering contracts,
- dependency rules,
- state ownership rules,
- Godot-native UI architecture decision,
- 2560×1440 reference-layout decision,
- architecture validation in CI,
- PR change checklist.

Exit conditions:
- a fresh session can recover project direction and current state from the repository,
- vision cannot reasonably be confused with implementation state,
- subsystem-specific engineering rules are discoverable,
- CI rejects initial high-risk dependency violations,
- reference UI geometry is explicit.

## Phase 2 — Infrastructure 2: Build & Recovery Pipeline

Purpose: let the non-coding project owner test repository changes without operating Godot or Git.

Planned scope:
- deterministic build metadata,
- Windows debug/preview export preset,
- PR preview build artifacts,
- build ID / commit ID visible in diagnostics,
- reproducible local and CI build commands,
- release artifact naming and retention rules,
- crash/debug report format.

Exit conditions:
- meaningful gameplay/UI PRs produce a runnable Windows artifact,
- a pasted debug report can identify the exact build and simulation state.

## Phase 3 — Walking Skeleton

Purpose: prove the first complete gameplay path without pretending to build the real game yet.

Target path:

```text
authored data
  -> authoritative state
  -> one simulation command
  -> state mutation
  -> presentation update
  -> UI
  -> save
  -> load
```

The behavior may be deliberately trivial. Architectural correctness matters more than game depth here.

## Phase 4 — Simulation Spine

Purpose: establish foundations required by a systemic simulation before complexity grows.

Planned capabilities:
- game clock,
- deterministic seeded RNG,
- stable entity IDs,
- authoritative state boundaries,
- command/input ordering,
- structured simulation events,
- reproducible state hashing,
- deterministic regression scenarios.

## Phase 5 — Persistence & Developer Tools

Purpose: make state durable, inspectable, and debuggable without source-code access.

Planned capabilities:
- versioned save schema,
- migrations,
- historical fixture saves,
- save/load roundtrip tests,
- simulation pause/step,
- state inspector,
- entity inspector,
- scenario runner,
- recent event log,
- copyable debug report.

## Phase 6 — OS + City Skeleton

Purpose: establish the final interaction architecture without filling it with fake systems.

Planned capabilities:
- native Godot OS shell,
- live city workspace placeholder,
- persistent rails contract,
- widget/app lifecycle,
- single-selection context model,
- alert/update/log semantics,
- shared Theme/tokens,
- responsive 2560×1440 reference layout,
- UI state separated from simulation state.

## Phase 7 — First Real Systemic Vertical Slice

Purpose: prove the actual game thesis.

One real opportunity should:
- exist in or connect to the city,
- surface through a glance-level interface,
- move into its management workflow,
- consume time/resources,
- produce consequences,
- change more than one authoritative system,
- persist through save/load,
- remain deterministic under the same seed/commands.

## Phase 8 — Simulation Expansion

Add major domains one at a time when dependency needs are real.

Likely domains include:
- people / crew,
- economy,
- pressure,
- relationships / contacts,
- neighborhoods,
- inventory / property,
- deeper operations.

Each domain must gain:
- one authoritative owner,
- explicit public API,
- persistence rules,
- tests,
- diagnostics,
- UI only after real state exists.

## Phase 9 — Scale & Production

Purpose: make the mature project safe to expand and release.

Likely capabilities:
- content authoring tools,
- content validation,
- asset/LFS policy,
- old-save compatibility suite,
- scenario library,
- performance budgets,
- long simulation soak tests,
- nightly deep health workflow,
- stable Windows release pipeline,
- release notes and tagged builds.

## Roadmap rules

1. Do not implement later-phase systems merely because the vision mentions them.
2. A phase can pull forward a tiny prerequisite when clearly justified.
3. Do not create empty framework folders for speculative systems.
4. Every phase updates `docs/state.md`.
5. Architecture changes that affect future work require an ADR.
6. Game-feel/design approval and engineering completion are separate concepts.
