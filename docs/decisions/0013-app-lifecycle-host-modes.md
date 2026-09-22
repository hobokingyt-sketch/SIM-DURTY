# ADR 0013: App Lifecycle, Host Modes and Navigation

Date: 2026-09-22
Status: Accepted for Phase 6C

## Context

Recovered Desktop Crime Sim research distinguishes City/Home, app-local Back,
center-region apps and rail-hosted apps. Apps resume state instead of behaving
like freshly loaded pages. The 6A/6B Godot workspace already preserves shell and
widget identity.

## Decision

1. Current apps are explicit. Do not populate the launcher with fake future
   Crew, Money, People or other domain applications.
2. Operations uses center-focus hosting. It replaces the visible center content
   while the same city node remains mounted with camera/selection continuity.
3. Session Record demonstrates right-rail hosting using only the bounded local
   event journal and real save-slot inspection.
4. City/Home returns to root. Back navigates only inside the active app.
5. Apps remember their last view for the current runtime. Route memory is
   presentation state, not gameplay persistence.
6. App views mount once. Inactive views suspend processing/input instead of
   being reconstructed or accumulating duplicate subscriptions.
7. Mounted view identity retains scroll state. Valid focus targets are remembered
   per view; city focus is restored after center-focus return when possible.
8. Deep links carry stable selected identity. Context opens Operations/Work with
   the same activity; Recent Activity opens Session Record/Activity.
9. No arbitrary overlapping floating windows are introduced.
10. Simulation, game saves and rail/widget preference formats remain unchanged.

## Consequences

The current app model is deliberately small. Future apps must declare host mode
and supported views rather than bypassing navigation. Cross-restart app-route
persistence is not introduced here. Final reactive/product acceptance remains 6D.
