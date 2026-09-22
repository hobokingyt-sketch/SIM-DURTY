# ADR 0004: Build Identity and Preview Artifacts

Status: Accepted
Date: 2026-09-21

## Context

The project owner does not normally operate source code, Git, or Godot.

Owner-facing playtesting therefore needs a reliable path from a repository change to a runnable Windows build, and bug reports need to identify the exact code that produced the observed behavior.

## Decision

1. Pull requests produce Windows preview artifacts.
2. Preview builds carry generated metadata derived from explicit Git/CI inputs.
3. Runtime code falls back clearly to `local-dev` when no generated manifest exists.
4. A plain-text debug report exposes build identity and later simulation identity.
5. The generated manifest and build outputs are not committed to Git.
6. Preview artifacts use a 14-day retention period.
7. Windows preview exports keep the PCK beside the EXE rather than embedding it.
8. Release/signing infrastructure remains a later production concern.

## Consequences

- Owner playtesting no longer depends on a local Godot setup.
- Bugs can be tied to exact build/source identities.
- Preview artifacts remain disposable and distinct from real releases.
- The build pipeline gains a small CI cost on pull requests.
- Later simulation diagnostics can extend the report without redesigning build identity.
