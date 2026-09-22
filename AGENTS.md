# SIM-DURTY AI Engineering Contract

This repository is the canonical source of truth for the project. Chat history is supporting context, never the sole authority.

## Core rules

1. Inspect the existing repository before changing architecture.
2. Keep the default branch bootable. Meaningful work happens on short-lived slice branches.
3. Use typed GDScript for production code.
4. Prefer small, focused scenes and composition over large inheritance trees.
5. Prefer signals or explicit interfaces over deep scene-tree lookups and hidden cross-system references.
6. Do not add an Autoload/global singleton without documenting why application-wide lifetime is required.
7. Simulation/domain state must not live inside UI Controls.
8. UI may display state and issue commands; it must not secretly become the authoritative simulation.
9. Never duplicate a system because the existing one is inconvenient. Refactor deliberately.
10. Never rewrite unrelated systems as collateral work for a feature.
11. Preserve deterministic simulation behavior where randomness or time affect gameplay.
12. Route meaningful randomness through the project's simulation RNG once that subsystem exists.
13. Version persistent save data. Never change a live save schema without a migration or an explicit compatibility decision.
14. Add or update tests whenever behavior changes.
15. A slice is not complete until the project imports, tests pass, the main scene boots, and docs/state.md reflects reality.
16. Treat warnings, dead code, orphaned resources, broken references, and duplicate logic as project health debt.
17. Do not hide failures with broad error suppression.
18. Keep authored gameplay data separate from code when Resources/data files are the clearer representation.
19. Optimize only after measurement unless a design creates an obvious unbounded cost.
20. Favor boring, inspectable infrastructure over clever abstractions.

## Repository ownership

- `game/app/`: application composition root and boot flow.
- `game/core/`: reusable technical foundations with no feature-specific UI.
- `game/simulation/`: world and simulation-domain logic.
- `game/features/`: vertically grouped gameplay features.
- `game/ui/`: shared UI shell, components, and screens.
- `tests/`: automated project health, unit, integration, and smoke tests.
- `docs/`: architecture, workflow, decisions, and current project state.

Folders should be created when they contain real files. Empty architecture theater is discouraged.

## Change protocol

For each meaningful slice:

1. Read `docs/state.md`, `docs/architecture.md`, relevant ADRs, and the touched code.
2. Define the smallest coherent behavior change.
3. Implement without unrelated cleanup.
4. Run/import the project headlessly.
5. Run automated tests.
6. Confirm the main scene boots.
7. Update tests and documentation.
8. Merge only after required health checks are green.

## Naming/style

- Files and folders: `snake_case`.
- Classes: `PascalCase`.
- Variables/functions/signals: `snake_case`.
- Constants: `UPPER_SNAKE_CASE`.
- Use tabs in GDScript.
- Use explicit return types and parameter types.
- Avoid vague names such as `thing`, `stuff`, `manager2`, or `temp_final`.

## Architectural default

Start local. Promote a dependency to global scope only when proven necessary.

The default flow is:

authored data -> simulation/domain logic -> authoritative state -> signals/view models -> presentation/UI

Do not reverse that dependency direction simply because a button was convenient.
