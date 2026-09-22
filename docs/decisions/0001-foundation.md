# ADR 0001: Foundation Architecture

Status: Accepted  
Date: 2026-09-21

## Context

SIM-DURTY will be developed primarily through conversation by a non-coding project owner while implementation is performed automatically against the Git repository. This increases the importance of explicit repository-local memory, automated validation, and low coupling.

## Decision

The project will:

1. Pin a stable Godot engine version.
2. Use typed GDScript.
3. Treat the Git repository as the canonical engineering record.
4. Build in small vertical slices.
5. Keep UI/presentation separate from authoritative simulation state.
6. Default to local ownership and composition instead of global singletons.
7. Add deterministic simulation foundations before simulation complexity grows.
8. Introduce versioned persistence before durable gameplay saves become important.
9. Run automated headless health checks in GitHub Actions.
10. Record architectural changes as ADRs when they meaningfully alter project-wide rules.

## Consequences

This adds a small amount of discipline to each change but dramatically reduces context drift, hidden coupling, and accidental regressions as the codebase grows.
