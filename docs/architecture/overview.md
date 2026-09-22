# Architecture Overview

SIM-DURTY grows through coherent vertical slices rather than a speculative framework.

## Runtime composition

`game/app/main.tscn` is the composition root.

Long-term shape may resemble:

```text
Main
├── GameSession
├── World
├── UI
├── Audio
└── DebugTools
```

These nodes are created only when required by real behavior.

## Dependency direction

```text
Authored Data
     ↓
Simulation / Domain Logic
     ↓
Authoritative State
     ↓
Presentation Adapter / Explicit References
     ↓
UI and Visual World
```

The application layer composes these pieces.

## Major repository areas

### game/app
Startup, composition, lifecycle wiring.

### game/core
Reusable technical foundations such as clock, deterministic RNG, IDs, persistence primitives, diagnostics, build metadata.

### game/simulation
Authoritative world state and state transitions.

### game/features
Vertically grouped gameplay behavior where co-location improves clarity without creating duplicated global state.

### game/ui
OS shell, shared presentation components, widgets, applications, context surfaces, alerts, Theme resources.

### game/content
Authored Resources/data. Content is data, not a second simulation implementation.

### game/devtools
Development-only inspection and control surfaces. They may observe broad project state but production gameplay must not depend on them.

### tests
Unit, integration, smoke, architecture, determinism, persistence, scenario, content, and performance tests as those capabilities appear.

## Architectural posture

Start local.

Promote a dependency or state owner to broader scope only when its lifetime and consumers justify it.

Avoid:
- global-manager proliferation,
- service-locator scene-tree traversal,
- duplicate authoritative state,
- UI-owned gameplay state,
- giant base classes,
- generic event buses replacing clear ownership,
- framework creation for hypothetical features.

## Detailed contracts

Read:
- `dependency_rules.md`
- `state_ownership.md`
- `ui_runtime.md`
- relevant ADRs in `docs/decisions/`
