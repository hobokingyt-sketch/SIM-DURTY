# Simulation engineering contract

Scope: game/simulation/**

- Read docs/architecture/state_ownership.md and ADR 0007 before changes.
- Simulation cannot depend on UI, app composition, wall-clock time or tree-based
  service discovery. No absolute /root dependencies.
- GameClock is the sole authority for simulation minutes/ticks. No second mutable
  elapsed counter or frame delta may decide domain outcomes.
- Randomness goes through SimulationRng. Raw randomize/randf/randi calls belong
  only in the core RNG wrapper, never domain code or UI.
- IdFactory owns the persisted event cursor. IDs are per-timeline, not global UUIDs.
- All domain commands validate sequence and complete preconditions before changing
  cash, time, RNG, ID cursor or notification state. Reject reentrant mutation.
- Snapshot methods return detached data. No subscriber may mutate authority.
- Preserve the distinction between snapshot (legacy three-value read model),
  spine_snapshot (simulation continuation), and checkpoint (both).
- Runtime save/load must preserve the FULL checkpoint. The legacy state-only
  overload exists for schema-one conversion/fixtures, not new production callers.
- Event records are bounded diagnostics. Do not invent historical records or
  convert their optional retention into hidden gameplay authority.
- Determinism requires the same initial checkpoint, ordered inputs, content and
  engine/source contract. Do not promise arbitrary engine-version equivalence.
- New state requires ownership, serialization, validation and regression coverage.
- No presentation strings/Controls, global event bus, speculative scheduler or
  unrelated gameplay domains are introduced merely to extend the spine.
