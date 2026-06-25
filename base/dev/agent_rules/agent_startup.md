# Agent Startup

## Required Startup

Read this file before answering any repository-specific question or doing any work in this repo. If you entered through `CLAUDE.md`, continue here and treat this file as the shared source of truth.

## Project Snapshot

This is a Godot 4.6 project built from the data-driven template base plus an optional preset overlay. The base provides data pipeline, boot orchestration, section-based save coordination, scene routing, unit test, headless check, placeholder SFX, localization, lint, and workflow skeletons.

## Agent Rules

Agent-specific instructions live in `dev/agent_rules/`. Read them before starting relevant work. Key rules: `sandbox_environment.md` (shell vs. file tools), `lint_before_finish.md` (run linter on changed files), `git_operations.md` (git is read-only unless the user explicitly asks for mutation), `godot_test_check.md` (never run Godot against the mount; use the /tmp snapshot procedure), `godot_tests.md` (how to run the GUT unit suite).

## Dev File Placement

Before creating or moving files under `dev/`, classify by the primary thing the file governs, not by who reads it:

- `dev/agent_rules/`: agent behavior and execution constraints. Use for sandbox, git permissions, lint/test requirements, headless checks, approval rules, and required agent habits.
- `dev/workflows/`: development process artifacts. Use for plan/spec/sketch/closeout/stage-review formats, lifecycle steps, and how work moves from idea to implementation. Slash-command workflow files live in `dev/workflows/commands/`.
- `dev/standards/`: project output standards. Use for code architecture, naming, scene structure, registries, themes, error guards, data conventions, change-summary tone, and other rules that define what correct repo artifacts look like.
- `dev/skills/`: concrete AI/Godot/GDScript recipes and hazard cards. Use for specific pitfalls, compiler/import failures, API traps, repeatable fixes, and commit/PR formatting references.
- `dev/docs/`: actual design, architecture, planning, and tracking documents. Use for feature plans, system docs, vision docs, archived plans, and product/design content.
- `dev/tools/`: executable tooling and tool-owned prompts. Use for scripts, validators, generators, hooks, and prompt packs used by those tools.

## Operating Rules

**No hard-wrapped prose**: Do not hard-wrap prose lines — let the client handle line wrapping. This applies to docs, summaries, commit messages, PR descriptions, and Markdown bullets.

Resolve unknowns by asking directly during the planning conversation. Do not leave unresolved decisions parked in a plan or spec.

## Workflow Commands

Command workflows live in `dev/workflows/commands/`. When asked to do a command task, read the matching file before acting and follow it exactly. Slash form, dash form, `cmd <name>`, and natural-language requests are all valid.

- `/closeout` -> `dev/workflows/commands/closeout.md`: closes out completed work — staged changes or a feature branch covering one or more plans.
- `/commit-msg` -> `dev/workflows/commands/commit-msg.md`: suggests a conventional commit message for currently staged changes.
- `/godot-test` -> `dev/workflows/commands/godot-test.md`: runs the safe `/tmp` snapshot Godot test workflow.
- `/pr-review` -> `dev/workflows/commands/pr-review.md`: reviews the branch against the base branch, then generates a PR title/description.
- `/stage-review` -> `dev/workflows/commands/stage-review.md`: checks staged changes against the plan spec and standards lint.
- `/research-context` -> `dev/workflows/commands/research-context.md`: retrieves relevant codebase context without implementing changes.

## Baseline Commands

- Generate data resources: `python dev/tools/yaml_to_tres.py --godot-root .`
- Render placeholder SFX: `python dev/tools/render_sfx.py --dir data/yaml/sfx/ --godot-root .`
- Generate localization CSV: `python dev/tools/localization_yaml_to_csv.py --godot-root .`
- Run standards lint: `python dev/tools/lint_standards.py --root .`
- Run unit tests: `godot_console --headless --path . --test-unit` from a safe environment; agents must use `godot_test_check.md`.
