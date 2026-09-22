# SIM-DURTY

SIM-DURTY is a Godot game project built through a chat-to-repository workflow.

## Foundation

- Engine: Godot 4.7.2 stable
- Language: typed GDScript
- Main scene: `game/app/main.tscn`
- Automated health: `.github/workflows/ci.yml`
- Engineering rules: `AGENTS.md`
- Current canonical state: `docs/state.md`

## Local health check

With Godot available as `godot` on Windows PowerShell:

```powershell
./tools/health_check.ps1
```

The same import and automated test checks run in GitHub Actions.

## Development model

Meaningful work is developed in short-lived `slice/*` branches, validated, then merged to `main`.

The repository is the canonical engineering record. Chat provides direction; durable architecture and project state live here.
