# Repository Map

This is the long-term repository shape. Directories should be created when they contain real project material; empty framework theater is discouraged.

```text
SIM-DURTY/
├── AGENTS.md
├── README.md
├── project.godot
├── .godot-version
├── .github/
│   ├── workflows/
│   └── pull_request_template.md
├── docs/
│   ├── START_HERE.md
│   ├── state.md
│   ├── roadmap.md
│   ├── health.md
│   ├── repository_map.md
│   ├── design/
│   │   ├── master_vision.md
│   │   ├── canon.md
│   │   ├── ui_principles.md
│   │   └── vocabulary.md
│   ├── architecture/
│   │   ├── overview.md
│   │   ├── dependency_rules.md
│   │   ├── state_ownership.md
│   │   └── ui_runtime.md
│   └── decisions/
├── game/
│   ├── app/
│   ├── core/
│   │   └── AGENTS.md
│   ├── simulation/
│   │   └── AGENTS.md
│   ├── features/
│   ├── ui/
│   │   └── AGENTS.md
│   ├── content/
│   │   └── AGENTS.md
│   └── devtools/
├── tests/
│   └── AGENTS.md
└── tools/
    └── validation/
```

## Growth policy

The map is directional, not a command to pre-create every folder.

Create a directory when:
- a real file needs its ownership boundary,
- a roadmap phase explicitly establishes the subsystem,
- keeping the file elsewhere would blur ownership.

Do not create:
- empty domain folders merely because the master vision names a future system,
- generic `managers/`, `helpers/`, or `utils/` dumping grounds,
- mirrored UI/simulation copies of the same domain model.

## Scoped AGENTS

The root `AGENTS.md` always applies.

A scoped `AGENTS.md` adds rules for its subtree.

Current scoped contracts:
- `game/core/AGENTS.md`
- `game/simulation/AGENTS.md`
- `game/ui/AGENTS.md`
- `game/content/AGENTS.md`
- `tests/AGENTS.md`

Add a new scoped contract only when a subsystem has distinct engineering risks that the root contract cannot express cleanly.
