# Roadmap

Build order is separate from product ambition. The matching PR/CI records
establish whether a revision passed validation and merged.

## 0. Foundation 0: COMPLETE
Bootable, tested Godot repository.

## 1. Project Memory & Guardrails: COMPLETE
Recovery entry point, vision/canon/state separation, scoped contracts, dependency rules.

## 2. Build & Recovery Pipeline: COMPLETE
Traceable Windows packages, native packaged-startup checks, checksums and debug reports.

## 3. Walking Skeleton: IMPLEMENTED IN THIS REVISION
One authored action -> one state owner -> UI -> explicit save -> reload.
Test surface and payouts are not final game design or economy balance.
Exit evidence: state/persistence/UI tests, native Windows two-process save/load,
rendered reference screenshots, and successful preview delivery. See ADR 0006.

## 4. Simulation Spine: NEXT
Controlled clock, seeded RNG, stable IDs, ordered commands/events and deterministic scenarios.
Add one narrow primitive at a time. Avoid replacing the working skeleton wholesale.

## 5. Persistence & Developer Tools
Migrations/fixtures, safer recovery UX, state/entity inspection, scenario runner,
simulation stepping and richer debug reports. Extend v1 with explicit compatibility.

## 6. OS + City Skeleton
Native shell, live city workspace, rails/widgets/apps/context/alerts, shared Theme/tokens.

## 7. First Real Systemic Vertical Slice
One actual opportunity connects city, management, time/resources, consequences and persistence.

## 8. Simulation Expansion
Major domains enter with one owner, explicit API, persistence, tests and diagnostics before UI.

## 9. Scale & Production
Content/asset tooling, save compatibility, scenario/performance/soak tests and durable releases.

## Rules
Vision does not authorize out-of-order implementation. Pull forward only narrow prerequisites.
No speculative empty frameworks. Update state/ownership when truth changes. Project-wide
architecture changes require ADRs. Engineering acceptance is not design acceptance.
