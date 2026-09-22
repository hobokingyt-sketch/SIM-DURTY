# Architecture Overview

SIM-DURTY grows through coherent vertical slices rather than a speculative framework.

## Runtime dependency direction

```text
Authored Data
     ↓
Simulation / Domain Logic
     ↓
Authoritative State
     ↓
Presentation Boundary
     ↓
UI and Visual World
```

The application layer composes the pieces.

Build identity and diagnostics are technical metadata. They may describe a runtime but never become gameplay state.

## Major repository areas

### game/app
Startup, composition, lifecycle wiring.

### game/core
Reusable technical foundations including diagnostics and build identity.

### game/simulation
Authoritative gameplay/world state and transitions.

### game/features
Vertical feature-local composition without duplicated shared authority.

### game/ui
OS shell and presentation.

### game/content
Authored Resources/data.

### game/devtools
Development-only observation/control; production gameplay must not depend on it.

### tests
Behavior and architecture validation.

### tools
Build, repository, and validation automation.

## Architectural posture

Start local. Promote scope only when real lifetime/consumer needs justify it.

Avoid:
- global-manager proliferation,
- service-locator tree traversal,
- duplicate authoritative state,
- UI-owned gameplay state,
- generic event buses,
- framework creation for hypothetical features.

## Detailed contracts

Read:
- `dependency_rules.md`
- `state_ownership.md`
- `ui_runtime.md`
- `build_pipeline.md`
- relevant ADRs in `docs/decisions/`
