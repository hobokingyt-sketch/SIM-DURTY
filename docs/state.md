# Project State

## Canonical project

Repository: `hobokingyt-sketch/SIM-DURTY`

Engine: Godot 4.7.2 stable  
Language: typed GDScript  
Primary branch: `main`  
Reference UI viewport: 2560×1440

## Current milestone

**Infrastructure 1 — Project Memory & Guardrails — COMPLETE**

Purpose: make long-running chat-to-game development recoverable and resistant to architecture/design drift.

## Implemented infrastructure

### Foundation 0
- [x] Repository bootstrapped
- [x] Godot version pinned
- [x] Project configuration
- [x] Application composition root
- [x] Runtime health diagnostic
- [x] Automated smoke test runner
- [x] GitHub Actions health workflow
- [x] Root AI engineering contract
- [x] CI verified on GitHub

### Infrastructure 1
- [x] Fresh-session recovery entry point
- [x] Source-of-truth authority model
- [x] Long-range master vision separated from implementation state
- [x] Durable design canon
- [x] Long-term roadmap
- [x] Repository map
- [x] Project health contract
- [x] Scoped AGENTS contracts
- [x] Dependency rules
- [x] State-ownership contract
- [x] Godot-native UI runtime contract
- [x] Godot-native UI ADR
- [x] 2560×1440 reference-resolution ADR/config
- [x] Pull-request health checklist
- [x] Architecture-guard script
- [x] Architecture guard wired into CI
- [x] Infrastructure 1 CI verified
- [x] Infrastructure 1 merged to main

## Runtime

The game intentionally contains no gameplay yet.

It still boots the Foundation status surface. Infrastructure 1 changes repository memory, validation, and reference geometry rather than adding gameplay.

## Gameplay systems

None implemented.

Systems described in the master vision are aspirational until this file and the code/tests record them as implemented.

## Save schema

No persistent gameplay save format exists yet.

## Autoloads

None.

## External addons

None.

## Next milestone

**Infrastructure 2 — Build & Recovery Pipeline**

Goal: produce reliable owner-facing Windows preview artifacts, build metadata, and debug identity so the non-coding project owner can test repository changes without operating Godot/Git.

## Health principle

New work should make the next feature easier without inventing infrastructure for hypothetical features.
