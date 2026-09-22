# ADR 0010: Functional OS Before Gameplay Expansion

Date: 2026-09-22
Status: Accepted priority correction from the project owner.
Implementation: Not completed by this documentation change.
Supersedes: ADR 0009's decision to defer core workspace interaction beyond the
OS phase, and the previous roadmap's immediate transition to gameplay expansion.
Does not invalidate the code or verified engineering results of PR #12.

## Context

The owner explicitly corrected the implementation order: engineer the UI with
its functionality first, using the existing Desktop Crime Sim prototype as a
source. The recovered UI_DECISION_MATRIX.md already states that gameplay waits
for OS, app flow, widget framework and interaction/visual approval. Its app-flow
contract includes center-region apps as well as rail apps, not only the right
Operations panel shipped in the Godot framing proof.

The previous roadmap confused avoiding infrastructure overhead with postponing
a core product system. Hands-off development must reduce owner chores, not
reduce the required UI functionality.

## Decision

1. Reopen Phase 6 as Functional Criminal OS. Do not begin Phase 7 gameplay-domain
   expansion until this bounded UI phase is functionally and visually accepted.
2. Preserve the v0.0.6 simulation, saves, diagnostics and delivery pipeline.
3. Use the recovered desktop design and code as behavioral references. Keep
   observed implementation, older source rules and new recommendations distinct.
4. Build workspace sizing, widget manipulation, semantic forms, app lifecycle,
   logical layout memory, reactive presentation and input isolation in visible
   slices. UI-first means working interaction, not an image-only design pass.
5. Use the existing session for real data/commands and isolated labeled fixtures
   for unavailable test states. Do not manufacture gameplay systems or display
   invented history as if it were real simulation state.
6. Keep the OS within authored regions. Explicit center-focus apps may replace
   the center presentation while preserving city continuity. Floating overlapping
   application windows are not inferred from the phrase 'OS-like'.
7. Keep presentation authority distinct from gameplay authority. UI preferences
   may persist independently; this does not authorize gameplay autosaving.
8. Reuse current tests/builds. Product acceptance includes actual geometry,
   information hierarchy and interaction feel, not only green runtime checks.

## Research limits and proposals

See docs/design/ui_os_research.md. The 0.68.12 standalone source was inspected,
not freshly interactively playtested: browser navigation was blocked by the
execution environment. Its implemented movable workspace covers bottom/right
regions, whereas its broader shell contract has four rails. The full engineering
bible referenced by the decision matrix was not recovered in this review.

Custom Godot Containers, preview/commit transactions, keyed reactive components
and separate preferred/effective layout state are engineering recommendations,
not claims that they already exist in SIM-DURTY or were all in the prototype.

## Consequences

The next implementation is workspace geometry and layout memory with visible,
functional results. There is no engine upgrade, save-schema change, new CI
workflow or gameplay implementation in this documentation pass.
