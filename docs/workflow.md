# Chat-to-Repository Workflow

The user provides game direction in plain language. The engineering workflow translates that direction into small repository slices.

## Standard slice

```text
User intent
    ↓
Repository inspection
    ↓
Small behavior contract
    ↓
slice/<number>-<name>
    ↓
Implementation
    ↓
Automated health checks
    ↓
Review / correction
    ↓
Merge to main
    ↓
docs/state.md updated
```

## User responsibilities

The user does not need to write code or operate Git for normal development.

The user's primary responsibilities are:
- define desired behavior,
- judge whether the game feels right,
- provide visual/design direction,
- playtest builds when experiential judgment is required,
- approve or reject design outcomes.

## Engineering responsibilities

The automated engineering side is responsible for:
- repository inspection,
- architecture,
- implementation,
- tests,
- migrations,
- dependency health,
- version control hygiene,
- CI health,
- keeping project documentation current.

## Slice sizing

A slice should produce one coherent outcome that can be described in a few sentences. Large ideas should be decomposed before implementation.

Good:
- add the simulation clock,
- add one profession loop,
- make dealer inventory persist,
- add the inspect panel.

Bad:
- build the entire economy, world, UI, AI, and save system in one change.

## Definition of done

A slice is complete when:
- project import succeeds,
- automated tests pass,
- the main scene boots,
- no known broken references were introduced,
- behavior matches the slice contract,
- project state documentation is updated.

Visual/game-feel work may additionally require user playtesting before being considered accepted.
