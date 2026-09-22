# UI Engineering Principles

This document translates the product-design intent into the Godot implementation.

## Native Godot

SIM-DURTY uses Godot-native UI.

Do not introduce an embedded browser/WebView merely to reproduce older HTML/CSS prototype wording.

Conceptual translations:

| Product/web concept | Godot implementation |
| --- | --- |
| Flexbox / CSS Grid | Containers and nested layout composition |
| CSS design tokens | Theme resources, constants, shared style resources |
| Component | Reusable Control scene/script |
| Responsive breakpoint | Available-size class / container-aware layout state |
| State class | Typed view state + explicit presentation method |
| CSS transition | Tween / AnimationPlayer / state animation |
| DOM reflow | Container-driven relayout |
| Web app shell | Authored Control/Container scene hierarchy |

## Reference geometry

The authored reference canvas is **2560×1440**.

This is a layout reference, not permission to hard-code every pixel.

Interfaces must:
- preserve comfortable typography,
- reflow before shrinking text,
- use containers rather than piles of manual offsets,
- remain coherent at supported smaller windows,
- protect the live city workspace where the product design requires it.

## UI state

UI/presentation state and simulation state are different categories.

Examples of presentation-owned state:
- selected tab,
- selected entity ID,
- expanded/collapsed section,
- widget layout,
- local sort/filter,
- transient animation phase.

Examples that must not be invented or owned by presentation:
- player cash,
- pressure,
- crew availability,
- operation outcome,
- simulation time.

UI reads authoritative state through explicit references/adapters and issues commands through defined interfaces.

## Components

Create a reusable component only when:
- it has a coherent purpose,
- reuse or independent testing is plausible,
- extracting it reduces rather than increases coupling.

Do not atomize the UI into tiny scenes merely to imitate a component framework.

## Motion

Use motion to explain:
- entering/leaving state,
- changed priority/order,
- expansion/collapse,
- value transition,
- operation phase,
- progress.

Avoid decorative perpetual animation without informational meaning.

## Visual discipline

No generic sci-fi HUD fallback.

No fake data.

No visual chart exists before the underlying data exists.

No microtext as a density strategy.

No proliferation of cards/borders merely to separate every value.


## Locked material direction

Read `docs/design/visual_north_star.md` before styling any production UI.

The implementation should evolve from the current flat StyleBoxFlat scaffolding
toward shared material/frame primitives. Reusable Theme styleboxes are preferred
for control-state consistency. Texture-backed nine-patch borders may be used for
scalable engineered frames; CanvasItem-compatible materials may provide the
subtle diffused charcoal grain on GUI elements when profiled and kept restrained.

Do not scatter local style overrides across individual apps to imitate the
concept one panel at a time. Build the material kit, then consume it.
