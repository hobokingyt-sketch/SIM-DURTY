# Project State

## Canonical project

Repository: `hobokingyt-sketch/SIM-DURTY`

Engine: Godot 4.7.2 stable  
Language: typed GDScript  
Primary branch: `main`  
Reference UI viewport: 2560×1440

## Current milestone

**Infrastructure 2 — Build & Recovery Pipeline**

Purpose: let the non-coding project owner test repository changes and report exact build identity without operating Godot or Git.

## Implemented infrastructure

### Foundation 0
- [x] Repository bootstrapped
- [x] Godot version pinned
- [x] Application composition root
- [x] Automated tests and GitHub health workflow
- [x] CI verified

### Infrastructure 1
- [x] Fresh-session recovery model
- [x] Vision/canon/state/roadmap separation
- [x] Scoped AGENTS contracts
- [x] Architecture guard
- [x] Dependency/state-ownership contracts
- [x] Native Godot UI and 2560×1440 decisions
- [x] CI verified and merged

### Infrastructure 2
- [x] Windows preview export preset
- [x] Explicit generated build manifest
- [x] Runtime BuildInfo fallback/reader
- [x] Copyable debug-report contract
- [x] Build ID/ref visible on boot surface
- [x] COPY DEBUG REPORT action
- [x] Local reproducible preview-build command
- [x] PR Windows preview workflow
- [x] Official matching export-template installation in CI
- [x] Preview ZIP naming and 14-day retention policy
- [x] Build metadata verification step
- [x] Infrastructure 2 health CI verified
- [x] Windows preview artifact verified
- [ ] Infrastructure 2 merged to main

## Runtime

The game intentionally contains no gameplay yet.

The boot surface now identifies Infrastructure 2, the current build/ref, and exposes a copyable debug report.

## Gameplay systems

None implemented.

## Save schema

No persistent gameplay save format exists yet.

## Simulation identity

No simulation seed or tick exists yet. Debug reports explicitly show `none` rather than inventing values.

## Autoloads

None.

## External addons

None.

## Next milestone

**Walking Skeleton**

Goal: prove one tiny complete path through authored data -> authoritative state -> command -> state mutation -> UI -> save -> load.

## Health principle

Owner-facing builds must be traceable to exact repository identity before gameplay complexity begins.
