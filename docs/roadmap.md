# Roadmap

This roadmap controls **build order**, not product ambition.

## Phase 0 — Foundation 0 — COMPLETE

Bootable, tested Godot repository.

## Phase 1 — Infrastructure 1: Project Memory & Guardrails — COMPLETE

Recoverable repository truth, scoped engineering contracts, architecture rules, and CI guardrails.

## Phase 2 — Infrastructure 2: Build & Recovery Pipeline — COMPLETE

Purpose: let the non-coding project owner test repository changes without operating Godot or Git.

Scope:
- explicit generated build metadata,
- Windows debug/preview export preset,
- PR preview artifacts,
- visible build/ref identity,
- copyable debug report,
- reproducible local/CI build commands,
- artifact naming and 14-day retention,
- build pipeline ADR/health contracts.

Exit conditions:
- pull requests can produce a runnable Windows artifact,
- artifact identity maps to exact source/build inputs,
- a pasted debug report identifies the exact build,
- generated build output is not committed,
- health and preview workflows are verified.

## Phase 3 — Walking Skeleton — NEXT

Purpose: prove the first complete gameplay path.

Target:

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

The behavior may be deliberately trivial. Architectural correctness matters more than game depth.

## Phase 4 — Simulation Spine

Game clock, deterministic RNG, stable IDs, authoritative boundaries, ordered commands/events, state hashing, deterministic scenarios.

## Phase 5 — Persistence & Developer Tools

Versioned save schema, migrations, fixture saves, state/entity inspection, scenario runner, simulation stepping, richer debug reports.

## Phase 6 — OS + City Skeleton

Native Godot OS shell, city workspace, rails/widgets/apps/context/alerts, Theme/tokens, responsive 2560×1440 layout.

## Phase 7 — First Real Systemic Vertical Slice

One real opportunity flows from city/glance through management, time/resources, consequences, persistence, and deterministic replay.

## Phase 8 — Simulation Expansion

Add major domains one at a time with one owner, explicit API, persistence, tests, diagnostics, then UI.

## Phase 9 — Scale & Production

Content tooling/validation, asset/LFS policy, save compatibility, scenario suite, performance/soak health, durable release pipeline.

## Roadmap rules

1. Vision does not authorize implementation out of order.
2. Pull forward only narrow prerequisites.
3. Do not create speculative empty frameworks.
4. Every phase updates `docs/state.md`.
5. Project-wide architecture changes require ADRs.
6. Design acceptance and engineering completion are separate.
