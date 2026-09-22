# Simulation Engineering Contract

Scope: `game/simulation/**`

Simulation owns authoritative gameplay/domain state and state transitions.

## Hard rules

- Simulation must not depend on `game/ui/`.
- Simulation must not depend on `game/app/` for service discovery.
- Do not discover dependencies through `get_tree().root` or absolute `/root/...` paths.
- Once `SimulationRng` exists, gameplay randomness must route through it.
- Once `GameClock` exists, gameplay time must route through it.
- Do not call `randomize()`, `randf()`, `randi()`, wall-clock time, or frame-time APIs to decide gameplay outcomes.
- Persistent entities require stable IDs once the ID system exists.
- Every authoritative field has one owner.
- Do not mirror mutable authoritative state in another simulation system.
- State changes happen through explicit typed methods/commands.
- Signals/events communicate what happened; they do not replace ownership.
- Same initial state + seed + ordered commands should produce the same authoritative result once determinism infrastructure lands.

## UI boundary

Simulation never formats presentation text, opens UI, owns tabs/widgets, or directly modifies Controls.

## Persistence

When persistent simulation state begins:
- schema ownership must be explicit,
- migrations are required for incompatible changes after a schema ships,
- tests must cover save/load roundtrips.
