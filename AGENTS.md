# SIM-DURTY AI Engineering Contract

This repository is the canonical source of truth for the project. Chat history is supporting context, never the sole authority.

## Session start

For a fresh or resumed engineering session, read `docs/START_HERE.md` first and follow its recovery order before changing code.

The root contract always applies. A nearer scoped `AGENTS.md` adds rules for its subtree.

## Source-of-truth rule

Never infer that a system exists merely because it appears in:
- `docs/design/master_vision.md`,
- `docs/roadmap.md`,
- old chat history.

Implementation truth comes from `docs/state.md`, code, and tests.

Accepted design truth comes from `docs/design/canon.md`.

Architecture truth comes from `docs/architecture/` and accepted ADRs.

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
15. A slice is not complete until architecture checks pass, the project imports, tests pass, the main scene boots, and `docs/state.md` reflects reality.
16. Treat warnings, dead code, orphaned resources, broken references, duplicate logic, and architecture exceptions as project health debt.
17. Do not hide failures with broad error suppression.
18. Keep authored gameplay data separate from code when Resources/data files are the clearer representation.
19. Optimize only after measurement unless a design creates an obvious unbounded cost.
20. Favor boring, inspectable infrastructure over clever abstractions.
21. Do not create empty framework folders for systems that only exist in the vision.
22. Project-wide architecture changes require an ADR.

## Repository ownership

- `game/app/`: application composition root and boot flow.
- `game/core/`: reusable technical foundations with no feature-specific UI.
- `game/simulation/`: world and simulation-domain logic.
- `game/features/`: vertically grouped gameplay features.
- `game/ui/`: shared OS shell, components, widgets, apps, context, alerts.
- `game/content/`: authored gameplay data/resources.
- `game/devtools/`: development-only inspection/control surfaces.
- `tests/`: automated project health and behavior tests.
- `docs/`: state, roadmap, design canon, architecture, decisions.
- `tools/`: repository/build/validation tooling.

See `docs/repository_map.md` for the long-term map.

Folders should be created when they contain real files. Empty architecture theater is discouraged.

## Change protocol

For each meaningful slice:

1. Read `docs/START_HERE.md` and relevant scoped contracts.
2. Confirm current `main` and inspect any overlapping active work.
3. Define the smallest coherent behavior/infrastructure change.
4. Identify state ownership before adding cross-system state.
5. Implement without unrelated cleanup.
6. Run the architecture guard.
7. Run/import the project headlessly.
8. Run automated tests.
9. Confirm the main scene boots.
10. Update `docs/state.md` and any canon/architecture truth that actually changed.
11. Merge only after required health checks are green.

## Naming/style

- Files and folders: `snake_case`.
- Classes: `PascalCase`.
- Variables/functions/signals: `snake_case`.
- Constants: `UPPER_SNAKE_CASE`.
- Use tabs in GDScript.
- Use explicit return types and parameter types.
- Avoid vague names such as `thing`, `stuff`, `manager2`, or `temp_final`.

## Architectural default

Start local. Promote a dependency to broader scope only when proven necessary.

The default flow is:

```text
authored data
-> simulation/domain logic
-> authoritative state
-> explicit presentation boundary
-> UI / visual world
```

Do not reverse that dependency direction simply because a button was convenient.
