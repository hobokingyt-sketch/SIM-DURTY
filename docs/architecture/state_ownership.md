# State ownership

## Current runtime

| State | Single owner | Mutation boundary |
| --- | --- | --- |
| Cash cents / completed errands | SkeletonSession | Validated work command |
| Integer simulation tick | GameClock owned by session | Work or explicit advance command |
| elapsed_minutes | Derived session read model | Never independently stored at runtime |
| Seed / RNG state / draw count | SimulationRng owned by session | Explicit RNG command; restore |
| Event ID cursor | IdFactory owned by session | One allocation per accepted command |
| Next command sequence | SkeletonSession | Successful ordered commit |
| Last diagnostic random draw | SkeletonSession | rng_probe command |
| Last 32 diagnostic events | SkeletonSession | Post-commit append; clear on restore/reset |
| Authored work definition | Session-owned copy of Resource | Construction, not UI editing |
| Saved checkpoint comparison | Main | Successful Save/Load |
| Formatting / control state | SkeletonView and SpinePanel | Read-only projections and request signals |
| Disk format/migration | SkeletonSave | Validate, stage, verify, back up, replace |
| Build identity | BuildInfo | Explicit build pipeline only |

Snapshots are detached copies. Main wires dependencies; UI never mutates clock,
RNG or money. A journal notification occurs after the whole command commits.
Reentrant writes are rejected while notifying subscribers. Availability queries
remain valid during notification so buttons do not become permanently disabled.

## Persistence boundary

Runtime saves pass snapshot AND spine_snapshot. Schema 2 must never be restored
from the three-value read model alone. Schema 1 conversion is the deliberate
exception, documented in ADR 0007. The tick and compatibility elapsed_minutes
fields must agree on read; a mismatch is rejected before changing live state.

Only one writer may operate a slot. Backup recovery and file locking remain
future work, not guarantees provided by this slice.
