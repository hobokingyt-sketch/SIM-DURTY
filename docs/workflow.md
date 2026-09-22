# Chat-to-Repository Workflow

The project owner provides game direction in plain language. Engineering work translates that direction into small repository slices.

The workflow is intentionally designed so the owner normally never needs to edit code or operate Git.

## Standard slice

```text
owner intent
    ↓
recover repository truth
    ↓
inspect current implementation
    ↓
define small slice contract
    ↓
slice/<number>-<name>
    ↓
implementation
    ↓
architecture guard
    ↓
import + tests + boot
    ↓
owner-facing preview/playtest when needed
    ↓
docs/state.md update
    ↓
PR → main
```

## Starting/resuming

Follow `docs/START_HERE.md`.

Never reconstruct current architecture only from chat history when the repository can answer the question.

## Owner responsibilities

The project owner primarily:
- defines desired behavior and game direction,
- judges whether the game feels right,
- gives visual/product feedback,
- playtests owner-facing builds,
- accepts/rejects design outcomes.

They should not normally need to:
- edit GDScript,
- resolve Git conflicts,
- configure CI,
- repair save files,
- identify which file owns a system,
- diagnose architecture from raw engine logs.

## Engineering responsibilities

The engineering side owns:
- repository recovery/inspection,
- architecture,
- implementation,
- tests,
- migrations,
- diagnostics,
- dependency health,
- version-control hygiene,
- CI health,
- build metadata,
- keeping canonical documentation truthful.

## Slice sizing

A slice should produce one coherent outcome describable in a few sentences.

Good:
- add the simulation clock,
- establish Windows preview export,
- add one profession loop,
- make dealer inventory persist,
- add the inspect panel.

Bad:
- build the entire economy, world, UI, AI, save system, and content pipeline in one change.

## Definition of done

A slice is engineering-complete when:
- architecture guard passes,
- project import succeeds,
- automated tests pass,
- main scene boots,
- no known broken references were introduced,
- behavior matches the slice contract,
- `docs/state.md` reflects reality,
- relevant canon/architecture docs are updated if their truth changed.

Visual/game-feel work may still require owner playtesting before design acceptance.

## Documentation discipline

- Vision changes go to `docs/design/master_vision.md`.
- Accepted durable design rules go to `docs/design/canon.md`.
- Build order goes to `docs/roadmap.md`.
- Current implementation goes to `docs/state.md`.
- Project-wide engineering decisions go to ADRs.
- Do not use one document as a dumping ground for all categories.
