# SIM-DURTY

SIM-DURTY is a Godot crime-management simulation project built through a chat-to-repository workflow.

## Start here

Read **`docs/START_HERE.md`** before engineering work.

## Project foundation

- Engine: Godot 4.7.2 stable
- Language: typed GDScript
- Reference UI viewport: 2560×1440
- Main scene: `game/app/main.tscn`
- Health workflow: `.github/workflows/ci.yml`
- Windows preview workflow: `.github/workflows/preview_build.yml`
- Windows export preset: `export_presets.cfg`
- Engineering rules: `AGENTS.md`
- Current state: `docs/state.md`
- Roadmap: `docs/roadmap.md`
- Build pipeline: `docs/architecture/build_pipeline.md`
- Debug-report contract: `docs/debug_report.md`

## Local health check

```powershell
./tools/health_check.ps1
```

## Local Windows preview

With matching Godot export templates installed:

```powershell
./tools/build/preview_build.ps1
```

Normal owner-facing development should use the automatically generated pull-request artifact rather than requiring local build tooling.

## Development model

Meaningful work uses short-lived `slice/*` branches, health checks, a Windows preview when owner-facing, then merge to `main`.

The repository is canonical engineering memory. Chat provides direction.
