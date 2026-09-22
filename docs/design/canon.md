# Design Canon

This file contains durable, currently accepted game-design rules.

It does **not** claim that the systems described here are implemented. Implementation truth lives in `docs/state.md`, code, and tests.

## Core fantasy

SIM-DURTY / Grit City is a desktop crime-management simulation built around a living city and a fictional criminal operating system.

The player starts small and gradually builds a criminal operation.

The intended blend is:
- strategy,
- management simulation,
- street-level crime simulation,
- light god-game,
- occupational/progression play.

The world should feel systemic rather than like a list of isolated scripted missions.

## Core loop

The durable conceptual loop is:

```text
observe city
-> notice useful work
-> inspect opportunity
-> prepare / assign resources
-> execute through Operations
-> deal with consequences
-> adapt
```

Systems should feed one another. A job should eventually matter beyond payout.

Avoid reducing the game to:
- a quest list,
- a static job menu,
- an RPG ability bar,
- disconnected minigames.

## City

The city is the main visual stage.

Whenever possible, meaningful simulation should eventually connect back to the city rather than exist only in tables.

The map should remain visually important while management UI is open.

## Criminal OS

The fictional operating system is the primary interaction architecture, not decoration.

The durable surface model is:
- live city workspace,
- persistent system rails,
- widgets,
- applications,
- alerts,
- contextual information.

Avoid unrelated floating windows and conventional RPG-menu structure.

## Widgets and applications

**Widgets summarize. Apps manage.**

A widget has one clear information purpose and helps the player understand whether something deserves attention.

An application provides the deeper management workflow.

Do not duplicate an entire application inside its widget.

## Selection and context

Selection should drive context.

Selecting a person, opportunity, property, district, vehicle, contact, or other supported entity should cause existing UI regions to respond intelligently.

Prefer transforming contextual content over spawning arbitrary extra panels.

## Information depth

Use progressive disclosure.

The durable hierarchy is:

1. **Glance** — immediate state in widgets/persistent OS areas.
2. **Work** — the application where the player manages that system.
3. **Context** — detail relevant to the current selection.
4. **Deep Detail** — breakdowns, modifiers, explanations, advanced information.
5. **Record** — history, logs, past events, reference information.

Do not show all five depths simultaneously.

## Information priority

Use these priority levels:

- **Critical** — needs attention immediately.
- **Active** — relevant to what the player is currently doing.
- **State** — useful for making a decision.
- **Detail** — useful when investigating further.
- **Archive** — historical/reference information.

Primary interfaces should mostly expose Critical, Active, and State.

## Alerts

Keep these concepts distinct:

- **Alert** — player intervention may be needed.
- **Update** — meaningful state changed.
- **Log** — something happened.

Not every simulation event deserves an alert.

## UI product direction

Treat the interface as a coherent contemporary product, not a futuristic HUD.

Quality should come primarily from:
- typography,
- spacing,
- alignment,
- hierarchy,
- responsive layout,
- surfaces,
- state,
- interaction,
- real data visualization,
- meaningful transitions,
- disciplined information density.

Avoid decorative vector graphics as the default design language.

Avoid solving quality with:
- random circles around values,
- targeting reticles,
- meaningless HUD marks,
- fake radar,
- decorative glow,
- fake maps,
- meaningless pulsing,
- generic progress bars everywhere,
- neon cyberpunk treatment,
- excessive borders/cards/gradients,
- every value becoming a badge.

Animation should communicate state or continuity.

## Data visualization

Different information may deserve different visual treatment.

Do not force every system into `label + number + horizontal bar`.

Only visualize data that actually exists. Never invent fake history merely to make the UI appear sophisticated.

## Legibility

The reference display is **2560×1440**.

Persistent information must be comfortably readable at that reference without zooming or leaning toward the screen.

When information does not fit:
- prioritize,
- reorganize,
- progressively disclose,
- increase available component space,
- remove redundant wording.

Do not solve density with microtext.

## Language

Use contemporary, grounded criminal language.

Avoid:
- faux noir,
- cheesy gangster terminology,
- unnecessary cop/procedural phrasing,
- RPG/class terminology,
- lore paragraphs that do not change play.

Text should explain what layout, numbers, state, or interaction cannot already communicate.

## Component-development rule

Build UI part by part.

For each widget/app:
1. define its single purpose,
2. establish information hierarchy,
3. build the responsive native-Godot shell,
4. engineer the real information components,
5. add interaction/state behavior,
6. add real visualization where useful,
7. add restrained motion,
8. test inside the full 2560×1440 reference layout,
9. remove anything that does not improve comprehension or decision-making.

Do not start with effects.

The goal is to make a deep simulation understandable, tactile, alive, and professionally engineered.
