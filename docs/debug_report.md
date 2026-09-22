# Debug report contract

Copy debug report is generated from the CURRENT session, not cached at startup.
BuildInfo supplies the existing game/build/commit/ref/engine identity.

Simulation Spine adds:

- milestone: Simulation Spine
- save_schema: 2
- simulation_seed: actual saved seed (default 184726)
- simulation_tick: actual integer minute tick
- clock_mode: command-driven; one tick = one minute
- next_command / next_event_id: persisted continuation cursors
- rng_draws / last_test_draw: actual test-stream state
- state_hash: full canonical authoritative checkpoint/content fingerprint
- cash_cents / elapsed_minutes / completed_actions: current domain values
- unsaved_session: comparison of the FULL checkpoint with the last Save/Load
- last_storage_error: last storage result

Build metadata is not simulation authority. The hash excludes build timestamp,
UI selection/layout and transient event journal. It is not an anti-cheat signature.
Do not expose local personal paths, environment variables or secrets in reports.
Do not guess fields when their owner is unavailable. See ADR 0007.
