SIM-DURTY 0.0.4 - SIMULATION SPINE

Extract the WHOLE ZIP to a folder, then open SIM-DURTY.exe.
Keep SIM-DURTY.pck beside the EXE. No Godot or Git installation is needed.
This is an unsigned development preview. Do not disable security software.

From a fresh session: run three errands -> $25.00 / Day 1 08:45 / 3 completed.
Save -> Reset session -> Load restores the saved checkpoint.
Close/reopen loads the saved slot. Unsaved changes are NOT saved on quit.

Step 1 minute / Step 15 minutes advances only the simulation clock.
Test random draw advances a saved diagnostic RNG stream; payouts stay fixed.
Save -> draw -> note value -> Load -> draw should repeat the same next value.
The state fingerprint identifies the complete simulation checkpoint.

Existing Walking Skeleton v1 saves are read without rewriting them. The next
explicit Save writes schema 2 and keeps the previous primary in its .bak file.
The slot filename still says slot_v1.json intentionally; the file's schema is
inside it. Use one game instance at a time. Backup recovery UI is not yet built.

Copy debug report and paste it into chat with the steps that caused a problem.
BUILD-METADATA.json identifies this build even if it cannot open.

This is still a temporary test surface, not the final Criminal OS. The clock is
command-driven: no automatic city simulation or offline progress is implemented.
Automated Windows validation covers packaged startup and separate-process
save/RNG/ID/clock continuation, not physical mouse, clipboard or GPU behavior.
