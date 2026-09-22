# SIM-DURTY AI Engineering Contract

This repository is canonical project memory. Chat history supports intent but is not the sole authority.

## Session start

Read `docs/START_HERE.md` before meaningful work.

Root rules always apply; nearer scoped `AGENTS.md` files add subtree rules.

## Source-of-truth rule

Never infer implementation from vision, roadmap, or old chat.

- Implementation truth: `docs/state.md` + code + tests.
- Accepted design: `docs/design/canon.md`.
- Architecture: `docs/architecture/` + ADRs.
- Build identity: generated manifest / `BuildInfo`, never guesses.

## Core rules

1. Inspect existing ownership before changes.
2. Keep `main` bootable; use short-lived slice branches.
3. Use typed GDScript.
4. Prefer focused scenes/composition over giant inheritance trees.
5. Prefer explicit references/signals over hidden tree discovery.
6. No Autoload/global without documented lifetime justification.
7. Simulation state never lives in UI Controls.
8. UI does not become authoritative gameplay state.
9. Do not duplicate systems for convenience.
10. Avoid unrelated rewrites inside feature work.
11. Preserve deterministic simulation behavior once those foundations exist.
12. Version persistent data and migrate incompatible shipped schemas.
13. Update tests with behavior.
14. Treat warnings/broken refs/duplicate state/disabled tests as health debt.
15. Generated build outputs and manifests remain untracked.
16. Owner-facing gameplay/UI work requires a successful preview artifact before playtest.
17. Do not fabricate build, save, seed, or tick identity.
18. Project-wide architecture changes require ADRs.
19. Create folders/systems only for real needs.
20. Favor boring, inspectable infrastructure.

## Repository ownership

See `docs/repository_map.md`.

## Change protocol

1. Recover repository truth.
2. Check active overlapping work.
3. Define a small slice.
4. Identify state ownership.
5. Implement without collateral redesign.
6. Run architecture guard, import, tests, boot.
7. Confirm Windows preview artifact for owner-facing work.
8. Update `docs/state.md` and any genuinely changed contracts.
9. Merge only after required gates are green.

## Naming/style

- files/folders: `snake_case`
- classes: `PascalCase`
- variables/functions/signals: `snake_case`
- constants: `UPPER_SNAKE_CASE`
- tabs in GDScript
- explicit parameter/return types

## Architectural default

```text
authored data
-> simulation/domain logic
-> authoritative state
-> explicit presentation boundary
-> UI / visual world
```

Build/debug metadata observes this runtime; it does not participate in gameplay authority.
