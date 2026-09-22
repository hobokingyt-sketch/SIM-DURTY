# Project State

Repository: hobokingyt-sketch/SIM-DURTY
Engine: Godot 4.7.2, unchanged
Language: typed GDScript
Game version: 0.0.11
Reference design: 2560x1440

## Current milestone: Functional Criminal OS, Phase 6D.2 — Engineered Frame System

This revision layers the locked frame grammar onto the 6D.1 material foundation
without changing the 6A–6C interaction contracts. Exact acceptance/merge status
belongs to the matching PR and exact-revision CI evidence. Gameplay expansion
remains blocked until the full Phase 6 visual/product acceptance under ADR
0010/0014.

## Implemented

All existing deterministic simulation, manual save/recovery, four-rail workspace
and movable-widget contracts remain.

- One typed app manifest defines only current real apps, host modes and views.
- Operations is a center-focus app. The city presentation hides while active,
  but the same CityBlockout node remains mounted, retaining camera and selection.
- Session Record is a right-rail app using only the real bounded event journal
  and save-slot inspection. No fake historical data or future-domain shell apps.
- City/Home is the stable root. Back is app-local. Reopening an app resumes its
  last view for the current runtime.
- Work context carries the selected activity into Operations. Recent Activity
  deep-links into Session Record/Activity with the same presentation authority.
- App views mount once. Hidden views suspend processing/input rather than being
  destroyed or duplicated. Existing scroll state stays with the mounted view.
- Each view remembers its last valid focus target; returning from center focus
  also restores prior city focus when the target still exists.
- Route, Back stack and app view memory remain presentation-only. They do not
  enter gameplay saves, RNG, state hashes or widget/rail preference formats.

## Ownership

OsAppManifest defines current app contracts. OsAppNavigation owns route,
remembered views and per-app Back history. OsPresentationState combines that
navigation with the shared selection. OsAppSurface owns mounted-view activation,
suspension and focus memory. CriminalOsShell composes surfaces with the existing
workspace without taking gameplay authority.

SkeletonSession/SkeletonSave, WorkspaceLayout/WorkspacePreferences, WidgetLayout
and WidgetWorkspace keep their previous authorities.

## Compatibility

Game slot remains user://walking_skeleton/slot_v1.json, schema 2 with v1 reader.
Rail and widget profile formats remain version 1. No migration, engine upgrade,
Autoload, addon or new workflow.

## Validation contract

Retain the prior 422 assertions and packaged Windows gates. 6C adds pure route
and presentation tests plus integrated center/rail app lifecycle, selection,
camera/focus continuity, remembered view, repeated-switch/no-node-growth and
gameplay/save isolation checks. Existing acceptance renders Operations and
Session Record at supported sizes. Packaged Windows validation routes the app
probe through the normal executable entry point.

Actual pass/fail evidence belongs to the matching exact-source PR run.

## Locked visual goal

The project owner accepted the charcoal engineered-OS concept as the visual
north star after Phase 6C. See `docs/design/visual_north_star.md` and ADR 0014.

The locked target now has both the 6D.1 charcoal material foundation and the
6D.2 scalable engineered frame grammar: true clipped/chamfered corners, layered
outer/structural/inner edges and restrained seam marks on shell, rails, apps and
widgets. Fine control/icon state treatment and typography remain later 6D passes.

## Limits and next

The city is still a static blockout with the existing errand. App view memory is
runtime presentation state, not a new persistent preference.

Next: Phase 6D.3 control and icon kit, followed by typography, reactive Work
Scan, second-surface proof, motion and final integrated OS acceptance.

Gameplay expansion remains blocked until the owner accepts the functional and
visual OS.
