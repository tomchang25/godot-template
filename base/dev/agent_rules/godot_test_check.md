# Godot Headless Check — Authoritative Safe Procedure

This file is the canonical safe snapshot and plain headless check procedure for the `/godot-test` workflow and any agent-run Godot headless check. Command wrappers should link here instead of duplicating the steps. Unit test details live in `godot_tests.md`.

Running `Godot --headless` directly against the mounted working tree is **forbidden** when the repo is on an unreliable cross-OS mount: the mount can serve tail-truncated views of recently-modified files, so Godot reports bogus parse errors that don't exist in the real files.

## Cross-OS mount warning

The safe snapshot procedure only works when `/tmp` is a container-native Linux filesystem. Do not point Godot editor/import/headless at any project directory or temporary snapshot path backed by a Windows bind mount.

Bad Docker Compose example:

```yaml
volumes:
  - 'E:/GodotProjects/godot-template/base:/workspace'
  - 'E:/tmp:/tmp'
```

The second mount defeats the procedure: `/tmp/godot-template.*` becomes another Windows/Docker Desktop mount, so Godot import can see stale or truncated files and emit bogus `.import`, UID, or resource-cache failures.

## Procedure

Materialize a clean snapshot from the git index into a sandbox-local directory and run there. Index/object-DB reads bypass unreliable working-tree reads.

```bash
cd <repo mount>
eval "$(python3 dev/tools/godot_test_setup.py --env)"       # creates $GT, copies dev/tools/bin, regenerates generated data
timeout 90 "$GODOT_BIN" --headless --path "$GT" --import   # import/setup phase: ignore errors and non-zero exit here
timeout 90 "$GODOT_BIN" --headless --path "$GT" --quit 2>&1 | grep -E "SCRIPT ERROR|Parse|ERROR:|push_error|FATAL"
```

`dev/tools/godot_test_setup.py` prints `GT`, `GODOT_TEST_SNAPSHOT_SOURCE`, and `GODOT_BIN` when called with `--env`. Report `GODOT_TEST_SNAPSHOT_SOURCE` with results: `index` means staged content; `HEAD` means the helper had to fall back to `git archive HEAD`, so staged-but-uncommitted changes are absent.

The helper requires PyYAML to already be installed for `python3`. In the `node:22-bookworm` agent image, install it once in the image/container with `apt-get update && apt-get install -y python3-yaml`; do not reinstall it during every test run.

The helper regenerates YAML `.tres` resources, placeholder SFX outputs, and localization CSV outputs inside the snapshot before Godot runs.

The `--import` invocation is setup only and is not the pass/fail result. The real plain-headless check is the second invocation: any unexpected error-level line there is a failure after applying caveats and cross-checking against the real repo files.

Multiple agents/sessions share `/tmp`, and files created by another session's user are not removable (`Permission denied`). That is why a fixed path like `/tmp/godot-template` is forbidden: `mktemp -d` guarantees a private dir. Don't bother cleaning up other sessions' leftovers; just ignore them.

## Caveats

- If `checkout-index` fails with `unknown index entry format`, the mount is serving a stale `.git/index`. Do not attempt repairs.
- If `checkout-index` fails, `dev/tools/godot_test_setup.py` falls back to `git archive HEAD` because object-DB reads are unaffected by the stale index. The snapshot is then **HEAD, not the index**: staged-but-uncommitted changes are absent. State clearly that the check ran against HEAD when reporting results.
- **The snapshot is the index, not the working tree.** Unstaged edits are absent. If results must reflect latest edits, ask the user to stage them first; do not run `git add` yourself unless explicitly requested.
- `*.uid` files are tracked and come along with checkout-index. If UID errors appear (`Unrecognized UID`, `Failed to instantiate an autoload`), the cause is a stale `.godot/` from an import that ran before the `.uid` files were in place; `rm -rf .godot` and re-import.
- `assets/`, `data/tres/`, `assets/audio/placeholder/`, `data/tres/audio_events/`, and `localization/generated/` are generated or gitignored. Missing generated-output warnings mean setup failed; missing source assets may still be expected noise in `/tmp` runs.
- Single-script checks outside `--path "$GT"` can collide with project `class_name` registrations. Always run with `--path "$GT"`.
- Any script error found in `/tmp` must be cross-checked against the real repo files before being reported as a real bug.
