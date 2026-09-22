# Dependency Rules

These rules protect dependency direction as the project grows.

They are intentionally small in Infrastructure 1. CI enforcement will expand only when real architecture exists.

## Layer rules

### game/core

May depend on:
- Godot engine APIs,
- other core modules.

Must not depend on:
- `game/ui/`,
- `game/simulation/`,
- `game/features/`.

Core is reusable technical infrastructure. It does not know gameplay presentation.

### game/simulation

May depend on:
- core foundations,
- explicitly defined authored data/resources.

Must not depend on:
- `game/ui/`,
- application composition,
- scene-tree service-location patterns.

Simulation is authoritative gameplay/domain logic.

### game/ui

May depend on:
- presentation-facing interfaces,
- shared UI components,
- explicit references supplied by the composition root.

UI must not become the owner of authoritative gameplay state.

### game/features

A feature may compose feature-local behavior and presentation, but:
- it must not duplicate authoritative shared state,
- shared domain logic belongs with its real owner,
- reusable technical primitives belong in core,
- cross-feature dependencies must be explicit.

### game/content

Authored data may describe gameplay.

It must not become hidden runtime orchestration.

### game/devtools

Devtools may inspect broad runtime state.

Production behavior must not require devtools to exist.

### game/app

The application/composition layer is allowed to know the major runtime systems because its job is to wire them together.

It should contain minimal domain logic.

## Forbidden shortcuts

Avoid:
- `get_tree().root` for dependency discovery,
- absolute `/root/...` NodePaths as a substitute for ownership,
- gameplay randomness outside the deterministic RNG once it exists,
- wall-clock time as gameplay simulation time,
- simulation importing UI code,
- core importing simulation/UI/feature code.

## Exceptions

A deliberate exception requires:
1. clear reason,
2. narrow scope,
3. ADR or code-level exemption rationale when the architecture guard would otherwise reject it,
4. follow-up removal plan if temporary.

Do not weaken the global rule merely to make one change convenient.
