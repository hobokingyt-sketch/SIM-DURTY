# Project Health Contract

Project health is a set of machine-verifiable and documented guarantees, not a vague feeling that the game launched once.

## Current required gates

Every meaningful slice should pass:

1. **Architecture guard**
   - required project-memory files exist,
   - initial dependency shortcuts are rejected.

2. **Godot import**
   - resources/scripts can be imported by the pinned engine.

3. **Automated tests**
   - current behavioral smoke tests pass.

4. **Main-scene boot**
   - the project can start the configured main scene headlessly.

5. **Repository truth**
   - `docs/state.md` accurately describes implemented capability,
   - architecture/canon docs are updated when their truth changes.

## Health gates that arrive with real systems

### Walking Skeleton
Add:
- unit tests for state mutation,
- integration test for state → presentation flow,
- save/load roundtrip.

### Simulation Spine
Add:
- deterministic RNG tests,
- clock tests,
- stable-ID tests,
- same-seed/same-command replay test,
- state hash comparison.

### Persistent schemas
Add:
- schema-version validation,
- historical fixture saves,
- migration tests,
- old-save compatibility checks.

### Content scale
Add:
- duplicate content-ID detection,
- missing reference validation,
- Resource-schema/content validation.

### OS/UI shell
Add:
- reference-layout smoke scenes,
- UI ownership checks where practical,
- screenshot/visual review artifacts when tooling supports them.

### Meaningful simulation scale
Add:
- scenario regression suite,
- performance budgets,
- long-running simulation/soak test,
- orphan/reference integrity checks.

### Production
Add:
- Windows export validation,
- preview artifact generation,
- tagged release workflow,
- build metadata,
- release smoke test,
- nightly deeper health workflow where runtime cost justifies it.

## Failure policy

Do not:
- disable a health gate simply because it found a real problem,
- convert errors into warnings to get a PR green,
- update expected results without understanding why they changed,
- merge known architecture damage as "temporary" without an explicit tracked decision.

A gate may be changed when the underlying contract intentionally changes. The code, test, docs, and ADR should then move together.

## Health debt

Examples:
- warnings,
- broken references,
- duplicate authoritative state,
- unused critical Resources,
- nondeterministic simulation outcomes,
- save migration gaps,
- architecture exceptions,
- failing/disabled tests,
- unbounded system cost.

Health debt should be recorded and deliberately resolved rather than buried in unrelated feature work.
