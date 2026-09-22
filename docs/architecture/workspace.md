# Workspace maintenance entry point

Read ADR 0011 for geometry, scale, storage and acceptance contracts.

- game/ui/os/workspace/workspace_layout.gd: deterministic preferences, fitting,
  bounds and resize transaction. No Nodes, input devices, disk or simulation.
- workspace_container.gd: one native Container applies all region rectangles;
  translates pointer coordinates and routes interaction cancellation.
- rail_handle.gd: hit/focus affordance and native keyboard/mouse start events.
- workspace_preferences.gd: bounded independent profile storage. Never point it
  at a gameplay save or replace an incompatible profile behind the owner.
- criminal_os_shell.gd: region content and read-only simulation presentation.
  Keep state/selection stable during layout. No frame polling or game-state mirror.

Preferred layout is what the owner chose. Effective geometry is the present
window's fit. Do not persist effective folding/shrinking caused by a smaller host.
Store one committed transaction, not every pointer move. Any new input path must
use the same solver and cancellation rules. A canceled edit cannot write storage.

The game reference is 2560x1440, not a demand to shrink every label into any
window size. Minimum supported host and scale fallback are explicit in ADR 0011.

All four rails are real shell regions. Movable widget packing/forms arrive in
6B with explicit allowed-region contracts. This phase must not silently become
a generic docking framework or a gameplay expansion.
