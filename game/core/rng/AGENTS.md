# Simulation RNG contract

Scope: game/core/rng/**

The SimulationRng wrapper is the only production location allowed to use the raw
Godot RandomNumberGenerator. Initialize explicitly; never call randomize.
Serialize internal 64-bit state as canonical decimal text, not a JSON number.
Restore seed before state. Reject incompatible engine/algorithm contracts rather
than silently reseeding. Keep draw counts and state continuation covered by tests.
Do not substitute a homemade algorithm or upgrade Godot without a deliberate ADR,
compatibility/migration decision and reproducibility tests. This RNG is for game
simulation, not security tokens, encryption or globally unique identifiers.
