# ADR 0003: UI Reference Resolution

Status: Accepted  
Date: 2026-09-21

## Context

The design canon defines 2560×1440 as the reference display and requires persistent information to remain comfortably readable there.

Foundation 0 temporarily used a 1600×900 viewport only as a bootstrap default.

A stable reference coordinate system is useful before the OS shell and widget geometry are authored.

## Decision

The project reference viewport is **2560×1440 (16:9)**.

Godot layout must use Containers/anchors/Theme-driven sizing so supported windows can scale or reflow without treating the reference as a fixed physical monitor requirement.

Local window overrides may be smaller for convenience, but authored UI decisions are evaluated against the 2560×1440 reference.

## Consequences

- UI screenshots and geometry reviews should identify the reference viewport.
- Persistent text may not be made illegibly small to fit the reference.
- Responsive behavior must prioritize/reflow/progressively disclose before shrinking typography.
- `project.godot` carries the reference viewport from Infrastructure 1 onward.
