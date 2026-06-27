# Claude Instructions

## Startup

Before answering any repository-specific question or doing any work in this layer, first read `dev/agent_rules/agent_startup.md`.

## Tool-Specific Notes

This file is the base-layer entry point for Claude-style agents that discover `CLAUDE.md`.

**Model-tier gate (Fable)**: if you are running as a Fable-class model, you may freely read individual files. If a task requires reading 10 or more files in a single operation (e.g. codebase-wide search sweeps, bulk lint passes, large diff reviews), stop and confirm with me first before proceeding.

This is the paradigm-neutral Godot template base layer. Detailed architecture, workflow, and standards guidance lives in `dev/agent_rules/agent_startup.md` and the files it references.
