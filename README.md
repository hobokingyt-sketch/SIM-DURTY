# SIM-DURTY

SIM-DURTY is a Godot crime-management simulation project built through a chat-to-repository workflow.

## Start here

For engineering/recovery context, read:

**`docs/START_HERE.md`**

That file defines the canonical reading order and prevents long-range design vision from being confused with implemented state.

## Project foundation

- Engine: Godot 4.7.2 stable
- Language: typed GDScript
- Reference UI viewport: 2560×1440
- Main scene: `game/app/main.tscn`
- Automated health: `.github/workflows/ci.yml`
- Engineering rules: `AGENTS.md`
- Current implementation state: `docs/state.md`
- Build order: `docs/roadmap.md`
- Accepted design canon: `docs/design/canon.md`

## Local health check

With Godot available as `godot` on Windows PowerShell:

```powershell
./tools/health_check.ps1
```

GitHub Actions additionally runs the architecture guard.

## Development model

Meaningful work is developed in short-lived `slice/*` branches, validated, then merged to `main`.

The repository is the canonical engineering record. Chat provides direction; durable project truth lives here.
