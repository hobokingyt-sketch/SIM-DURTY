# Project State

## Canonical project

Repository: `hobokingyt-sketch/SIM-DURTY`

Engine: Godot 4.7.2 stable  
Language: typed GDScript  
Primary branch: `main`  
Reference UI viewport: 2560×1440

## Current milestone

**Infrastructure 2 — Build & Recovery Pipeline**

Baseline export/build-identity implementation is complete (PRs #6 and #7).
Delivery hardening adds a mandatory packaged-Windows startup gate. A branch's
actual validation result is its matching CI run, not a checkbox in this file.

Purpose: let the non-coding project owner test repository changes and report
exact build identity without operating Godot or Git.

## Implemented infrastructure

### Foundation 0
- Repository bootstrapped; engine pinned; application composition root.
- Automated tests and GitHub health workflow.

### Infrastructure 1
- Fresh-session recovery and vision/canon/state/roadmap separation.
- Scoped AGENTS contracts and architecture guard.
- Dependency/state-ownership contracts.
- Native Godot UI and 2560×1440 decisions.

### Infrastructure 2
- Windows preview export preset with separate EXE/PCK.
- Explicit generated build manifest and runtime BuildInfo fallback/reader.
- Build/ref identity on the boot surface and COPY DEBUG REPORT action.
- Local PowerShell preview-build command.
- PR export workflow with matching official editor/templates.
- Generated outputs remain outside tracked source.
- Exact-source import, architecture checks, tests, manifest check, and export.
- Native Windows packaged-startup validator with negative-test fixtures.
- Checksum verification, isolated path-with-spaces launch, timeout, error-log
  checks, and sidecar/runtime/source identity matching.
- Verified preview is published only after Windows Packaged Boot succeeds.
- Owner instructions, SHA-256 sidecar, logs, and machine-readable test evidence.
- Candidate artifacts expire after 1 day; verified previews and logs after 14.

## Runtime

No gameplay systems exist yet. The unchanged boot surface identifies
Infrastructure 2 and the build/ref, and exposes a copyable debug report.

## Save and simulation identity

No persistent gameplay save format, seed, or simulation tick exists. Reports
show `none` rather than invented values. Autoloads: none. External addons: none.

## Validation boundary

The new delivery gate validates native Windows headless startup and build
identity. Graphical appearance, input/clipboard, audio, performance, and save
compatibility are not covered by that gate. Record owner playtest results
separately. See `docs/architecture/build_pipeline.md` and ADR 0005.

## Next milestone

**Walking Skeleton**

One tiny path through authored data -> authoritative state -> command ->
state mutation -> UI -> save -> load. It has not started in this slice.

## Health principle

Deliver the tested artifact from the tested revision. Do not mistake an
export, a candidate upload, or a status document for runtime verification.
