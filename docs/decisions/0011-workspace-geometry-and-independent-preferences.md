# ADR 0011: Workspace Geometry and Independent Preferences

Date: 2026-09-22
Status: Accepted implementation direction for approved Phase 6A.
Acceptance evidence: matching PR and exact-revision CI, not this document.

## Scope

Implement operable workspace geometry and layout memory before widget dragging,
semantic widget forms, multi-app lifecycle and further gameplay expansion.
Retain the existing simulation, schema-two game saves and delivery workflows.

## Source rules retained

From ADR 0010 and recovered Desktop Crime Sim research: four connected rails,
full-height sides, horizontal rails between them, a 2560x1440 design reference,
32x18 conceptual grid with 80-unit cells, 20-unit rail steps, protected 1440x800
city at the reference, and an icon-first embedded launcher. This pass does not
claim that the entire reference's material/visual treatment is finished.

## Implementation decisions

WorkspaceLayout is the sole rail geometry owner. WorkspaceContainer applies
its region and separator rectangles. RailHandle routes actual pointer/keyboard
input into the same model used by the click controls. OsPresentationState no
longer owns a duplicate glance-visibility field. Controls within rails remain
native container layouts; the city is still the authored static blockout.

Geometry has 8-unit outer margins and 12-unit manipulation seams, each counted
once. Preferred defaults are left/right 300, top 100, bottom 200. Expanded
minimums are left 240, right 280, top 80, bottom 120. The different content
minimums are deliberate, not interchangeable with collapsed shell thickness.
Collapsed sides retain 64 units, horizontal rails 48. Side collapse leaves the
launcher usable. The workbench's selected content scrolls inside its own region.

### Available-size policy

Stop uniformly shrinking the 2560x1440 reference into a smaller window.
Godot stretch mode is disabled: at 100 percent, one UI unit is one viewport
pixel. Declared minimum content/window size is 1280x800. The city reservation
is ceil(1440 * min(width/2560, 1)) by ceil(800 * min(height/1440, 1)) in current
logical units. At the reference it is exactly 1440x800; at 1600x900 it is 900x500.
These smaller-window minimums are an explicit implementation policy, not claimed
as an original prototype rule. Large windows keep the original reservation.

Preferred and effective layout are distinct. Deterministic fitting reduces the
right/bottom region first, then its opposing region, to bounded content minima.
If necessary in constrained hosts, effective regions fold without changing their
preferred state. The solver is not a generic arbitrary docking/packing engine.

An optional 125-percent interface scale enlarges the workspace through its
single presentation transform. It requires at least 1600x1000 physical content
space. A smaller window temporarily uses 100 percent while retaining the larger
preference. No automatic text scale below 100 percent is used. Input positions
are transformed into workspace coordinates. Actual size captures test geometry;
this is not a claim of universal OS/DPI/accessibility certification.

### Interaction transactions

Rail dragging starts a preview, snaps to 20-unit steps, and clamps against the
opposing effective rail and city minimum. Releasing commits at most once. Escape,
right-click, focus loss, or a changed available viewport cancels the preview.
Direct manipulation is immediate, not tween-delayed. Arrow keys operate a focused
splitter; Enter/double-click folds it. The Layout workbench also supplies ordinary
clickable step/fold controls. A fold remembers the preferred expanded size.

### Independent layout memory

WorkspacePreferences stores version-one logical preferences in a separate
user://ui_workspaces namespace, keyed by the associated game slot's hash. Only
committed UI changes write the profile. Load and window fitting do not write.
Gameplay saving remains manual, and layout preferences are excluded from RNG,
simulation fingerprints and game save schema. Reset layout affects preferences
only, not the city camera or game session.

Profiles are bounded, structurally validated, staged and read back before
replacement. Missing profiles use defaults. Corrupt, oversized, or future
profiles are retained and not silently overwritten; the live UI uses a safe
fallback and reports a storage error. This is not an automatic profile repair
system, multi-writer lock or a new power-loss durability guarantee.

Existing tests/probes use nonpersistent UI defaults so they never inherit owner
preferences; explicit workspace tests opt into isolated profile locations.
Windows acceptance writes a layout using viewport-dispatched input and restores
it in another process while checking unchanged gameplay bytes and identity.

## External API references checked

https://docs.godotengine.org/en/stable/classes/class_container.html
https://docs.godotengine.org/en/stable/classes/class_control.html
https://docs.godotengine.org/en/stable/classes/class_window.html

These support custom container layout and native input/scale mechanisms. Actual
compatibility is verified with the repository's pinned engine through CI.

## Remaining Phase 6 work

6B adds widget manipulation and authored responsive forms. 6C develops full app
hosting/lifecycle. 6D completes reactive product components and integrated UI
acceptance. The existing Work Scan is still a minimal live adapter, not proof of
those future features. Do not advance to new gameplay domains after 6A alone.
