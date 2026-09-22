# UI Engineering Contract

Scope: `game/ui/**`

The UI implements the Criminal OS presentation architecture.

Read:
- `docs/design/canon.md`
- `docs/design/ui_principles.md`
- `docs/design/visual_north_star.md`
- `docs/architecture/ui_runtime.md`

## Hard rules

- Use native Godot Control/Container/Theme architecture.
- Reference design size is 2560×1440.
- UI does not own authoritative gameplay state.
- UI may own presentation state such as selection, tabs, local filters, expansion, widget layout, and transient animation.
- UI issues explicit commands rather than directly mutating distant simulation internals.
- Do not invent fake data for charts, history, trends, or sophistication.
- Do not solve layout pressure by shrinking text into microtext.
- Prefer container-driven layout/reflow over piles of manual offsets.
- Avoid generic futuristic HUD/vector decoration as a fallback.
- The locked material goal is charcoal/graphite, diffused matte texture, layered engineered borders, restrained brass accents and machined/chamfered geometry.
- Centralize visual primitives in the shared Theme/material/frame system; avoid one-off per-screen styling when a shared primitive should own it.
- Motion communicates state/continuity.
- Widgets summarize; apps manage.
- Selection should update existing contextual surfaces before spawning arbitrary new panels.
- Preserve progressive information depth: Glance → Work → Context → Deep Detail → Record.
- Player-facing text follows `docs/design/vocabulary.md`.

## Component rule

Create reusable Control scenes where they clarify ownership or real reuse. Do not atomize every label and row into framework-style components.
