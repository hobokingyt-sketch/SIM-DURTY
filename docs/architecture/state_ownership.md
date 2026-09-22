# State Ownership

Every authoritative field has one owner. Other systems read detached snapshots
or request changes through an explicit API; they do not keep competing mutable copies.

## Implemented ownership

| State | Owner | Mutation API | Persistent? |
| --- | --- | --- | --- |
| cash_cents | SkeletonSession | perform_work / restore / reset | Yes, v1 |
| elapsed_minutes | SkeletonSession | perform_work / restore / reset | Yes, v1 |
| completed_actions | SkeletonSession | perform_work / restore / reset | Yes, v1 |
| authored payout/duration | skeleton_errand.tres | authoring; session copies on creation | Content, not mutable save state |
| save envelope and disk slot | SkeletonSave | write_state / read_state | v1 format |
| last successful saved snapshot | Main | after successful save/load | No; comparison baseline only |
| status text, button state | SkeletonView | show_state / show_status | No |
| build identity | BuildInfo / generated manifest | build pipeline | Build metadata only |

Main composes these objects. SkeletonSession imports no UI or filesystem code.
SkeletonSave validates data but cannot mutate a session. Main restores only a
successful validated read. UI owns no money, outcome, or authoritative time.

## Categories

Authoritative state determines outcomes. Presentation state controls how state
is viewed. Derived state (including the unsaved indicator) must identify its
source inputs and must never become another authority.

## When adding fields

Record precise meaning, one owner, mutation API, readers, persistence/schema
implications, determinism inputs/order, and whether the field is derived.

Future crew, pressure, city, inventory, RNG, and tick ownership is not implemented.
Do not infer it from the master vision. See ADR 0006 for this limited slice.
