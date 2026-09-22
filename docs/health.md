# Project Health Contract

Project health is machine-verifiable behavior, not the comforting sensation that something launched once.

## Current required health workflow

Every meaningful slice must pass:

1. **Godot import**
2. **Architecture guard**
3. **Automated tests**
4. **Main-scene boot**
5. **Repository-truth review**

## Current owner-facing preview workflow

Every pull request also attempts a **Windows Preview** build:

1. install pinned Godot,
2. install matching official export templates,
3. generate explicit build metadata,
4. verify the metadata,
5. export the Windows preview,
6. package EXE/PCK/build receipt,
7. upload a short-lived artifact.

A gameplay/UI slice is not ready for owner playtesting until its preview artifact succeeds.

## Build identity health

Generated preview builds must expose:
- build ID,
- commit/source SHA,
- ref,
- CI run identity,
- game/Godot versions.

Development without generated metadata must identify itself as local rather than fabricating Git identity.

## Gates that arrive with real systems

### Walking Skeleton
Add:
- unit tests for state mutation,
- integration test for state -> presentation flow,
- save/load roundtrip.

### Simulation Spine
Add:
- deterministic RNG tests,
- clock tests,
- stable-ID tests,
- same-seed/same-command replay,
- state hash comparison.

### Persistent schemas
Add:
- schema-version validation,
- fixture saves,
- migration tests,
- old-save compatibility.

### Content scale
Add content-ID/reference/resource validation.

### OS/UI shell
Add reference-layout smoke coverage and visual-review artifacts where useful.

### Meaningful simulation scale
Add scenario regressions, performance budgets, soak tests, and orphan/reference integrity checks.

### Production
Add signed/tagged release workflow, durable release artifacts, release smoke tests, and deeper scheduled health checks.

## Failure policy

Do not disable or weaken a gate merely because it found a real problem.

A contract may change deliberately, but code, tests, docs, and ADRs must move together.
