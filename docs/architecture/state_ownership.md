# State Ownership

Every authoritative field has one owner.

Other systems may read it or request a change through an explicit interface, but they do not maintain competing copies.

## Categories

### Authoritative simulation state

Determines gameplay outcomes and must survive or reproduce correctly.

Examples later may include money, pressure, people, operations, neighborhoods, inventory, simulation time.

### Presentation state

Controls how authoritative state is viewed.

Examples:
- selected entity,
- current app/tab,
- local sort/filter,
- expanded section,
- widget placement,
- transient animation state.

Presentation state must not quietly become gameplay state.

### Derived state

Computed from authoritative inputs.

Prefer recomputing or explicitly caching derived state rather than creating an undocumented second authority.

## Current ownership table

Infrastructure 1 intentionally has no real gameplay state yet.

| State | Owner | May modify | Notes |
| --- | --- | --- | --- |
| Foundation boot status | runtime diagnostic / app | boot flow | Diagnostic only; not gameplay |
| Main scene composition | `game/app` | application layer | Startup ownership |
| Future gameplay state | **not implemented** | **not implemented** | Vision does not imply existence |

## Required process when adding state

Before introducing a persistent or cross-system field, document:

| Question | Required answer |
| --- | --- |
| What is the state? | Precise meaning |
| Who owns it? | One authoritative module/object |
| Who can mutate it? | Explicit command/API |
| Who can observe it? | Known consumers |
| Is it persistent? | Yes/no and schema implications |
| Is it deterministic? | Inputs/order requirements |
| Is it derived? | Source fields and cache policy |

Update this file when a major ownership boundary appears or changes.

## Anti-patterns

Do not:
- mirror authoritative values inside UI controls,
- keep two mutable copies and "sync" them,
- let unrelated systems directly edit each other's internals,
- infer ownership from whichever script first needed the value,
- put shared state in an Autoload solely because access is convenient.
