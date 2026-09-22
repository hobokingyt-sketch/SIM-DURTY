# START HERE

This is the recovery entry point for SIM-DURTY.

The project is designed to be developed primarily through chat by a non-coding owner while engineering work is performed against this repository. A fresh engineering session must be able to recover the project without relying on old chat history.

## Read in this order

1. `/AGENTS.md`
2. `/docs/state.md`
3. `/docs/roadmap.md`
4. `/docs/design/canon.md`
5. `/docs/architecture/overview.md`
6. `/docs/architecture/dependency_rules.md`
7. `/docs/architecture/state_ownership.md`
8. The nearest scoped `AGENTS.md` for the files being changed
9. Relevant ADRs in `/docs/decisions/`
10. Relevant code and tests
11. Recent Git history and any active pull request

Read `/docs/design/master_vision.md` when the task concerns long-range product direction. Do not use it as evidence that a described system already exists.

## Authority model

Different files answer different questions.

| Source | Answers |
| --- | --- |
| `docs/state.md` + code/tests | What exists now? |
| `docs/design/canon.md` | What design rules are currently accepted? |
| `docs/architecture/*` + ADRs | How is implementation allowed to work? |
| `docs/roadmap.md` | What order do we intend to build things? |
| `docs/design/master_vision.md` | What kind of game are we ultimately trying to make? |
| Chat history | Supporting intent and discussion, not sole canonical memory |

When sources conflict, stop treating the conflict as permission to guess. Resolve it deliberately and update the repository.

## Critical distinction

**Vision is not implementation.**

A system described in `master_vision.md` does not exist until `state.md`, code, and tests say it exists.

A planned system in `roadmap.md` does not exist until it is implemented and recorded in `state.md`.

A rejected idea must not remain in `canon.md`.

## Resume protocol

Before making a meaningful change:

1. Confirm the work starts from current `main`.
2. Read the authority sources above.
3. Inspect the actual files that own the behavior.
4. Check for an existing active slice/PR touching the same area.
5. Define the smallest coherent slice.
6. Work on `slice/<number>-<name>`.
7. Run the architecture guard, import, tests, and main-scene boot.
8. Update `docs/state.md` and any changed canon/architecture documents.
9. Merge only after required health checks are green.

## Project-owner contract

The project owner should normally be able to work by describing desired behavior, judging playtest results, and making design decisions.

They should not be required to:
- edit GDScript,
- resolve Git conflicts,
- understand CI YAML,
- manually repair save files,
- inspect engine internals,
- discover which file owns a system.

Engineering infrastructure exists to absorb that complexity.
