# Architecture

## Foundation 0

SIM-DURTY starts with a deliberately small architecture. The project should grow by adding coherent vertical slices rather than pre-building a speculative framework.

## Composition root

`game/app/main.tscn` is the application composition root.

Future high-level runtime composition should resemble:

```text
Main
├── GameSession
├── World
├── UI
├── Audio
└── DebugTools
```

These nodes should appear only when the game actually needs them.

## Dependency direction

```text
Authored Data
     ↓
Simulation / Domain Logic
     ↓
Authoritative Game State
     ↓
Presentation Adapter / Signals
     ↓
UI and Visual World
```

UI is presentation. It is not authoritative game state.

## System boundaries

### app
Owns startup and composition of major runtime systems.

### core
Technical foundations that can be reused by multiple gameplay features. Examples: deterministic RNG, clock, IDs, persistence, diagnostics.

### simulation
Authoritative world behavior and state transitions.

### features
Feature-local scenes, scripts, Resources, and presentation when a vertical feature benefits from co-location.

### ui
Reusable presentation shell/components and larger screens that span multiple features.

## Global state policy

Autoloads are not banned, but they require a documented reason. A dependency should remain local unless its lifecycle is genuinely application-wide and global access is clearer than explicit ownership.

## Communication policy

Prefer:
- direct references from an owning composition root,
- signals for one-to-many notifications,
- typed method calls for explicit commands,
- Resources for authored data.

Avoid:
- repeated `get_tree().root...` traversal,
- hidden NodePath dependencies across distant scenes,
- UI controls mutating unrelated systems directly,
- broad event buses used as a substitute for architecture.

## Determinism target

Gameplay-affecting randomness and time should become reproducible once the Simulation Spine milestone lands. The future target is that a seed plus the same ordered inputs produces the same simulation result.

## Persistence target

Persistent data will carry an explicit schema version. Schema changes require migration or an explicit compatibility break recorded in an ADR.

## Performance policy

Measure first. Profile actual frame time, memory, node count, physics, and simulation cost before introducing complexity for hypothetical scale.
