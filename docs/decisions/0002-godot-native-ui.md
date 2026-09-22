# ADR 0002: Godot-Native UI

Status: Accepted  
Date: 2026-09-21

## Context

The long-range design source originated partly from HTML/CSS prototypes and contains implementation language such as CSS Grid, Flexbox, container queries, DOM transitions, and state classes.

The production project is now a native Godot game.

The product-design intent behind those terms remains valuable: responsive composition, strong hierarchy, reusable components, state-driven interaction, and meaningful motion.

## Decision

Production UI will use Godot-native `Control` scenes, Containers, Themes, Tweens/AnimationPlayer, and typed presentation state.

No embedded browser/WebView will be introduced merely to preserve the older HTML/CSS implementation wording.

Conceptual mapping is documented in `docs/design/ui_principles.md`.

## Consequences

- The product-design philosophy remains canonical.
- HTML/CSS-specific instructions in the master vision are interpreted as conceptual ancestry rather than literal implementation requirements.
- A future browser surface would require a separate justified ADR.
- UI architecture remains integrated with Godot input, scene lifecycle, testing, and performance tooling.
