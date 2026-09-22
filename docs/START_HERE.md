# START HERE

This is the recovery entry point for SIM-DURTY.

The project is designed to be developed primarily through chat by a non-coding owner while engineering work is performed against this repository.

## Read in this order

1. `/AGENTS.md`
2. `/docs/state.md`
3. `/docs/roadmap.md`
4. `/docs/design/canon.md`
5. `/docs/architecture/overview.md`
6. `/docs/architecture/dependency_rules.md`
7. `/docs/architecture/state_ownership.md`
8. nearest scoped `AGENTS.md`
9. relevant ADRs
10. relevant code/tests
11. recent Git history and active PRs

Read `docs/design/master_vision.md` for long-range product direction only.

For build/export/recovery issues also read:
- `docs/architecture/build_pipeline.md`
- `docs/debug_report.md`

## Authority model

| Source | Answers |
| --- | --- |
| `docs/state.md` + code/tests | What exists now? |
| `docs/design/canon.md` | What design rules are accepted? |
| `docs/architecture/*` + ADRs | How may it be engineered? |
| `docs/roadmap.md` | What comes next? |
| `docs/design/master_vision.md` | What are we ultimately trying to make? |
| debug report / build metadata | Which exact build produced observed behavior? |
| Chat history | Supporting intent, not sole canonical memory |

## Critical distinctions

**Vision is not implementation.**

**A build report is not gameplay state.**

Do not invent seed/tick/save identity before those systems exist.

## Resume protocol

1. Confirm current `main`.
2. Read the authority sources.
3. Check overlapping active PRs.
4. Inspect actual owning files.
5. Define the smallest coherent slice.
6. Work on `slice/<number>-<name>`.
7. Run architecture/import/tests/boot.
8. Require Windows preview success for owner-facing work.
9. Update canonical docs.
10. Merge only after required gates are green.

## Project-owner contract

The owner should normally provide behavior/design direction and playtest results.

They should not need to edit code, operate Git, configure CI, build exports, repair saves, or identify implementation ownership.
