# Repository Map

This map grows only when real files need the ownership boundary.

```text
SIM-DURTY/
├── AGENTS.md
├── README.md
├── project.godot
├── export_presets.cfg
├── .godot-version
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── preview_build.yml
│   └── pull_request_template.md
├── docs/
│   ├── START_HERE.md
│   ├── state.md
│   ├── roadmap.md
│   ├── health.md
│   ├── debug_report.md
│   ├── repository_map.md
│   ├── design/
│   ├── architecture/
│   │   ├── overview.md
│   │   ├── dependency_rules.md
│   │   ├── state_ownership.md
│   │   ├── ui_runtime.md
│   │   └── build_pipeline.md
│   └── decisions/
├── game/
│   ├── app/
│   ├── core/
│   │   ├── AGENTS.md
│   │   ├── build/
│   │   └── debug/
│   ├── simulation/
│   ├── features/
│   ├── ui/
│   ├── content/
│   └── devtools/
├── tests/
└── tools/
    ├── build/
    └── validation/
```

## Growth policy

Create a directory only when a real file or roadmap capability needs it.

Do not create speculative domain folders because the master vision mentions future systems.

## Generated paths

These are intentionally not canonical source:
- `game/core/build/generated/`
- `build/`

They are regenerated from explicit source/build inputs and are Git-ignored.

## Scoped AGENTS

The root contract always applies. Current scoped contracts exist for:
- core,
- simulation,
- UI,
- content,
- tests.

Add another only when a subtree develops distinct engineering risks.
