# UI Runtime Architecture

The Criminal OS is gameplay architecture, but presentation still remains downstream from authoritative state.

## Reference layout

Reference design size: **2560×1440**.

Use Containers and Theme-driven layout so the interface can adapt to supported window sizes.

The reference size is a design coordinate system, not an excuse for brittle absolute positioning.

## Runtime flow

```text
authoritative state
    ↓
presentation-facing data / explicit reference
    ↓
Control scenes
    ↓
user action
    ↓
explicit command
    ↓
authoritative state transition
```

UI does not directly reach into distant simulation nodes and mutate fields.

## Surface model

Long-term product surfaces may include:
- live city workspace,
- persistent rails,
- widgets,
- applications,
- contextual information,
- compact alerts.

These are design contracts, not evidence that the corresponding systems are implemented.

## Widget/app contract

Widget:
- one glance-level purpose,
- summarizes current real state,
- may hand selection/intent into an application,
- does not reproduce the entire application.

Application:
- manages the deeper workflow,
- preserves a clear master hierarchy,
- may expose context/deep detail progressively.

## Selection

Selection should have one presentation owner.

Other UI regions react to the current selection rather than creating competing selection stacks.

The eventual selected value should normally be a stable entity ID/reference, not a mutable duplicate of the entity.

## Theme and tokens

Shared visual decisions should move into Theme resources/shared constants rather than being manually repeated across every scene.

Examples:
- typography scale,
- spacing scale,
- radii,
- surfaces,
- semantic colors,
- focus/hover/disabled states.

Do not build a giant theme framework before actual components need these tokens.

## Motion

State-driven only.

Prefer Tween/AnimationPlayer for:
- reordering,
- entering/leaving,
- expansion,
- value transition,
- progress,
- status change.

Avoid motion that exists only to make the screen appear active.
