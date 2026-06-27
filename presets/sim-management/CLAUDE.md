# Claude Instructions

## Startup

Before answering any repository-specific question or doing any work in this preset, first read `../../base/dev/agent_rules/agent_startup.md`, then read the preset standards under `dev/standards/` that match the task.

## Tool-Specific Notes

This file is the sim-management preset entry point for Claude-style agents that discover `CLAUDE.md`.

**Model-tier gate (Fable)**: if you are running as a Fable-class model, you may freely read individual files. If a task requires reading 10 or more files in a single operation (e.g. codebase-wide search sweeps, bulk lint passes, large diff reviews), stop and confirm with me first before proceeding.

This preset overlays turn, idle, management, and UI-heavy Store/System conventions on the base template. Detailed architecture and task-specific rules live in the base startup file and this preset's standards.
