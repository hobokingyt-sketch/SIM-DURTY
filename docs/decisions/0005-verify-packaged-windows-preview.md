# ADR 0005: Verify the Packaged Windows Preview Before Delivery

Status: Accepted
Date: 2026-09-22

## Context

Infrastructure 2's first implementation exported and uploaded a Windows ZIP
on Linux. Its successful export did not establish that the delivered EXE/PCK
would start on Windows or that packaged metadata matched the source identity.
The owner does not operate the build toolchain and needs stronger evidence.

## Decision

Preserve the Linux exporter, then add a dependent native Windows validation
job. Validate the checksum, unpack outside the source checkout, launch the
actual exported EXE with a timeout, and check runtime identity and error logs.
Only this job may publish the verified owner-facing artifact. Keep candidate
artifacts clearly separate and short-lived. Preserve diagnostic evidence.
Use `.godot-version` as the preview toolchain version source, and run source
health checks against the exact commit being exported.

## Consequences

This adds one Windows CI job and transfer artifact per preview run. It verifies
portable headless startup, not visual or clipboard correctness. The existing
local export helper remains an engineering utility, not the delivery gate.
No gameplay, simulation, UI design, save system, or engine upgrade is introduced.
