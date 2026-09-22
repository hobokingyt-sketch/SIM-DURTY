# Build & Recovery Pipeline

Infrastructure 2 produces traceable Windows previews without requiring the project owner to operate Godot, Git, or build tools.

## Build identity

`game/core/build/generated/build_manifest.json` is generated and Git-ignored.
`BuildInfo` reads it; unstamped source runs clearly use `local-dev` instead.
The manifest records schema, channel, build ID, exact checked-out commit,
source SHA, ref, build number, workflow run ID, PR, explicit UTC build time,
game version, and Godot version. Run attempts are included in the CI build
number so retries are distinguishable.

The same explicit manifest inputs produce the same manifest. This is not a
claim that Windows binaries or ZIP archives are byte-reproducible between runs.

`DebugReport` combines build identity with actual runtime state. There is no
save schema, simulation seed, or simulation tick yet; these report `none`.
Reports do not include usernames, local paths, environment dumps, or secrets.

## Required delivery sequence

`.github/workflows/preview_build.yml` runs for runtime/tooling PR changes and
manual dispatch. Documentation-only changes retain the existing preview skip.

1. Check out the exact PR head SHA and verify it against the intended source.
2. Read `.godot-version`; install that editor and matching templates outside
   the Godot project so downloaded tooling is not imported as game content.
3. Wait for full import using `--import`. Run the architecture guard and tests
   against this same checkout. Reject engine error output as well as nonzero exits.
4. Generate and verify the manifest. Export the Windows Preview preset.
5. Package EXE, separate PCK, metadata, and owner instructions. Compute SHA-256.
6. Upload a short-lived `candidate-` artifact strictly for cross-job transfer.
7. On a native Windows runner, verify the ZIP checksum and extract to a fresh
   path containing spaces outside the repository checkout.
8. Verify required files and identity. Launch the exported EXE, without using
   an editor or `--path` back to the source project, with a bounded timeout.
9. Require successful exit, the configured main scene's boot marker, Windows
   platform, and runtime metadata matching both the sidecar and expected SHA.
   Reject reported script/resource/runtime errors even if the exit code is zero.
10. Publish the exact tested ZIP and its checksum only after that check passes.

The smoke validator has positive and intentionally invalid log fixtures, so its
failure detection is tested too. Windows verification writes `verification.json`
and stdout/stderr/engine logs as a separate diagnostic artifact.

`Windows Packaged Boot` is the delivery gate. An exported file, a candidate
artifact, or a documentation checkbox alone is not proof of a working preview.

## Artifact names and retention

Verified build: `SIM-DURTY-preview-<run>-a<attempt>-<short-sha>` (14 days).
Its GitHub download contains the game ZIP plus a `.sha256` checksum sidecar.
Cross-job candidate: the same name prefixed `candidate-` (1 day).
Diagnostics: `export-logs-<run-id>-a<attempt>` and
`windows-verification-<run-id>-a<attempt>` (14 days).

Do not deliver candidate artifacts as validated builds. The workflow summary
links to the verified artifact. Preview expiry is deliberate; durable releases
remain a later milestone. Retain the previously working preview separately.

## Owner workflow

Extract the complete game ZIP and open `SIM-DURTY.exe`. Keep its PCK beside it.
No Godot installation is required. The current screen is an infrastructure
status surface with build/ref identity and COPY DEBUG REPORT, not gameplay.
When reporting a problem, paste that report and describe the behavior. If the
program cannot launch, `BUILD-METADATA.json` still identifies the build.

The preview is unsigned. Verify its source/checksum; do not disable antivirus
or other system protections. Never mix files from different builds.

## Local engineering reproduction

The existing `tools/build/preview_build.ps1` generates a local preview using
Git identity and an installed Godot/editor template pair. This helper is not
required for the project owner's workflow, and a local export is not a
CI-verified artifact.

The new `tools/build/verify_windows_preview.ps1` uses PowerShell 7 on Windows.
Its `-SelfTest` mode tests validation logic. Normal mode requires a CI preview
archive, exact SHA, expected archive hash, exact engine version, and a report
directory. It leaves verification evidence outside the extracted application.

## Validation limits

The gate proves native Windows **headless startup and packaged identity**.
It does not prove rendered UI appearance, clipboard behavior, audio, long-run
stability, save compatibility, or performance on the owner's hardware. Those
need their appropriate tests/playtesting as the roadmap introduces them.

CI has read-only repository permissions and does not retain Git credentials.
No privileged `pull_request_target` workflow is introduced. `needs: export`
orders the two jobs; only the Windows job publishes a verified preview.

## Primary references

- Godot command-line import/export: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Windows export format: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html
- GitHub cross-job artifacts: https://docs.github.com/en/actions/tutorials/store-and-share-data
