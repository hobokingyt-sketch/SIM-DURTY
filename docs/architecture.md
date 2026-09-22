# Architecture Index

The detailed architecture moved into scoped documents so this file remains a stable compatibility entry point.

Start with:

1. `docs/architecture/overview.md`
2. `docs/architecture/dependency_rules.md`
3. `docs/architecture/state_ownership.md`
4. `docs/architecture/ui_runtime.md`
5. relevant ADRs in `docs/decisions/`

For fresh-session recovery, begin at `docs/START_HERE.md`.

## Core principle

```text
Authored Data
     ↓
Simulation / Domain Logic
     ↓
Authoritative State
     ↓
Presentation Boundary
     ↓
UI / Visual World
```

The application layer composes systems. UI is downstream from gameplay authority.
