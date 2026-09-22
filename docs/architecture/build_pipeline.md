# Build & Recovery Pipeline

Infrastructure 2 gives every preview build a traceable identity and produces Windows artifacts automatically from pull requests.

## Build identity

Generated build metadata lives at:

`res://game/core/build/generated/build_manifest.json`

The generated directory is intentionally ignored by Git.

Tracked code provides a safe local fallback when no generated manifest exists.

A generated build identity contains:
- manifest schema,
- build channel,
- build ID,
- exact commit SHA,
- source SHA,
- branch/ref,
- CI run number,
- workflow run ID,
- pull-request number when applicable,
- explicit UTC build time,
- game version,
- Godot version.

## Determinism rule

The manifest writer does not invent identity from runtime state.

Its metadata comes from explicit environment inputs supplied by Git/CI or the local build script.

For the same explicit inputs, the generated manifest is the same.

Build time is an explicit input and is therefore traceable rather than silently sampled inside the game.

## Runtime recovery

`BuildInfo` reads the generated manifest when present.

Without a manifest, development runs use a clear `local-dev` fallback rather than pretending to be a CI build.

`DebugReport` combines build identity with runtime state in a copyable plain-text format.

As simulation infrastructure arrives, the report will gain real save schema, seed, tick, selected entity, and diagnostic state without changing the build-identity contract.

## Windows preview artifact

Pull requests with owner-facing/project-runtime changes run `.github/workflows/preview_build.yml`.

Documentation-only changes under `docs/**`, `README.md`, and the PR template intentionally skip the Windows preview because they cannot change the runnable game.

The workflow:
1. checks out the exact source revision used for the preview,
2. installs the pinned Godot editor,
3. installs the matching official export templates,
4. generates build metadata,
5. imports the project,
6. verifies build metadata,
7. exports the `Windows Preview` preset,
8. places `BUILD-METADATA.json` beside the export,
9. packages the Windows directory as a ZIP,
10. uploads it as a GitHub Actions artifact.

The Windows PCK is intentionally not embedded into the executable.

## Owner workflow

The project owner should not need to run the export pipeline.

Normal flow:

```text
chat direction
-> implementation PR
-> CI health
-> Windows preview artifact
-> owner playtest
-> correction or merge
```

The engineering assistant should surface the relevant preview artifact whenever owner-facing testing is needed.

## Local reproduction

With Godot export templates installed and Git available:

```powershell
./tools/build/preview_build.ps1
```

The script uses the current Git commit and branch as the local preview identity.

## Artifact naming

CI ZIP:

`SIM-DURTY-preview-<run-number>-<short-sha>.zip`

GitHub artifact name uses the same identity.

Preview artifacts are short-lived test outputs, not releases.

## Retention

Preview artifacts default to 14 days.

Durable player/release builds will use the later release pipeline rather than extending preview retention indefinitely.
