# Widget Maintenance Contract

Phase 6B implementation: see ADR 0012. Root/UI AGENTS and UI-first roadmap apply.

## Ownership

- WidgetLayout: stable registry, validate/normalize, move/form proposals, pure fit.
- WidgetWorkspace: mounted views, preview session, input, profile coordination.
- WidgetDock: scroll boundary, canvas, candidate outlines.
- WidgetHandle: focusable native move/resize pointer and key affordances.
- WidgetView: existing work/event readouts and semantic internal composition.
- WorkspacePreferences: shared bounded profile IO; explicit rails/widgets codecs.
- CriminalOsShell: composition and forwarding to existing selection/command owners.

## Rules for follow-on work

Keep a single placement decision for pointer, keyboard and click-menu actions.
Do not mutate preferred data during preview or persist fitted geometry. Preserve
component IDs and focus rather than recreating the shell after changes. A widget
must not own cash/time/RNG, execute work implicitly on a drop, or fabricate history.

When adding a widget, deliberately evolve the registry and profile version or
migration: unknown IDs are currently rejected, not silently erased. Validate minima
with actual longest content and own-control bounds. Only declare new allowed regions
when their packing behavior exists. Four shell rails do not imply free placement
everywhere. Keep source/render/Windows tests in existing workflows.

Current forms use limited real data. Expanding their product design is 6D work,
not permission to replace persistent controls with whole-tree rebuilds or to invent
new gameplay data. App lifetime/center hosting comes next in 6C.
