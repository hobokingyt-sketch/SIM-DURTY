# ADR 0009: Native OS and City Skeleton

Status: Accepted
Date: 2026-09-22

## Scope

Move the accepted test activity into the real interaction architecture without
inventing the city simulation or changing the existing saved timeline.

## Decision

The shell uses native Godot Controls and Containers. A shared Theme is assembled
from OsTokens. Four authored regions frame the city: top navigation/time,
left glance widgets, right context/Operations and bottom status/storage/drawers.
The left glance region can be collapsed. Developer tools and records are optional
mutually exclusive drawers; no floating desktop windows are introduced.

Work Scan and the city marker both select the existing authored activity ID.
Context hands that selection to Operations. Only the Operations work button
emits the existing work command. Opening/closing apps never advances gameplay.
The city Control remains mounted while applications switch, retaining camera
center, zoom and selected work. UI selection belongs to OsPresentationState;
camera belongs to CityBlockout. Neither enters the simulation checkpoint.

CityBlockout is an explicitly labeled, authored spatial fixture. Roads, buildings,
canal and one errand marker are presentation geometry, not simulated businesses,
actors, travel routes or invented economic data. There is no autonomous motion,
world generation, fake history or additional live opportunities.

The session still owns all cash/time/RNG/IDs. Main wires existing commands and
passes detached state/events to the shell. The legacy SkeletonView class/scene
is a small compatibility adapter so existing runtime and recovery tests remain
valid; it does not run a second UI or a parallel simulation.

Status distinguishes actionable errors/recovery from routine updates. Recent
activity displays only the bounded existing journal, explicitly not saved history.
Save/Load/recovery and the same schema-2 slot (including v1 reader) are retained.

## Deliberate limits

This first shell has authored region sizes, not a widget-layout editor. Arbitrary
widget dragging, grid reflow, rail resizing and per-save UI layout persistence
remain future UI work. Camera and selection survive navigation in this running
session, not application restarts. The city itself remains a static blockout.
Do not describe this as a completed living city or the full criminal OS.

## Acceptance

Retain prior tests and packaged persistence/recovery probes. Add selected-ID
validation, widget/app handoff, no-mutation navigation, camera retention, bounded
zoom, no duplicate app instances, drawer lifecycle, event/alert semantics and
native packaged OS navigation acceptance. Capture city, Operations and developer
drawer at 2560x1440 and 1600x900 through the existing render workflow.

Headless button-signal tests do not replace physical input/GPU playtesting.
Actual results attach to the exact PR revision. No additional CI workflow,
engine upgrade, save schema or simulation framework is introduced.

## Reference

Godot Control and Container APIs supply input isolation and responsive native
layout. Custom CanvasItem drawing supplies only the authored spatial blockout.
- https://docs.godotengine.org/en/stable/classes/class_control.html
- https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html
- https://docs.godotengine.org/en/stable/classes/class_canvasitem.html
