# ADR 0014: Charcoal Engineered OS Visual North Star

Date: 2026-09-22  
Status: Accepted and locked by project owner.

## Context

After Phase 6C established app lifecycle and navigation, the owner approved a
specific concept render as the visual target for SIM-DURTY. The image replaces
generic “dark contemporary OS” wording with a concrete material and frame
language: diffused charcoal surfaces, layered engineered borders, restrained
warm brass accents and machined control shapes.

## Decision

1. `docs/design/visual_north_star.md` is the canonical visual target.
2. The current flat Godot theme is functional scaffolding and may be replaced
   aggressively as long as 6A–6C interaction contracts remain intact.
3. Visual implementation must be centralized in reusable Theme/material/frame
   primitives. One-off local styling is not the default.
4. Major surfaces use diffused charcoal material treatment plus explicit depth
   hierarchy. Texture remains subtle and never interferes with information.
5. Layered border/frame grammar is a first-class design system. Chamfered,
   engineered geometry is preferred over pill-shaped generic UI.
6. Warm brass/sand is scarce semantic emphasis, not a universal decoration.
7. No neon/glass/HUD drift. No fake data or decorative radar is introduced as
   part of visual polish.
8. Phase 6D is split into ordered visual-engineering and reactive-product passes
   before final integrated OS acceptance.
9. UI screenshots are product evidence. Bounds tests and logic tests do not
   override visible clipping, hierarchy failure or material inconsistency.

## Godot implementation direction

Use native Godot mechanisms. Theme resources/styleboxes should carry shared
control states. Nine-patch/texture-backed frame resources are appropriate for
repeatable scalable borders. CanvasItem-compatible materials may supply the
subtle surface texture where they remain cheap and deterministic.

Do not embed a browser or replace the existing native Control/Container
architecture to reproduce the concept image.

## Consequences

6D begins with material/frame primitives before polishing individual widgets.
Gameplay expansion remains blocked until integrated 6D acceptance and owner
approval. The target is visual fidelity to the design language, not pixel-for-
pixel reproduction of one generated concept screenshot.
