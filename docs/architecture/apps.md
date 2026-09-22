# OS App Lifecycle

Phase 6C separates app definition, route state, selection and mounted view
lifecycle instead of making each screen discover or rebuild the others.

## Pieces

- OsAppManifest: current app IDs, host modes and supported views.
- OsAppNavigation: City/app route, remembered view and app-local Back stack.
- OsPresentationState: shared selected entity/work plus navigation composition.
- OsAppSurface: stable mounted views with activate/suspend and focus memory.

## Host modes

Center apps replace the visible city presentation while active. The city node is
not freed or reconstructed. Returning reveals the same camera and selection.

Right-rail apps replace right contextual content while leaving the city visible.

Host mode is authored per app. It is not a user-floating desktop window system.

## Navigation

City/Home is root. Back pops only the current app's local view history.
Reopening an app resumes its last runtime view. Deep links may request a
particular view and selected identity; invalid identities fail without inventing
state.

## Lifetime and continuity

Views are created once and keep stable node identity. Inactive views are hidden
and process-disabled. Existing ScrollContainers therefore retain their scroll
state naturally. Each view remembers a valid focus target and restores it on
reactivation. Center-focus return similarly restores a valid prior city focus.

No app surface owns simulation results or game-save authority.
