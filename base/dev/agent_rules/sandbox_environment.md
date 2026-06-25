# Sandbox Environment — Shell vs. File Tools

The sandboxed Linux shell can return **phantom file corruption** for files in this repo — blocks of NUL bytes, mid-token truncation, "binary file matches", or wrong byte counts — especially right after a write. This is a mount artifact, NOT real disk damage. The Read/Edit file tools are authoritative.

## Rules

- The Read/Edit file tools are authoritative. After modifying a file, verify it with Read, never by `cat`/`hexdump`/`wc`/`grep` through the shell. If Read shows clean content, the file is fine.
- Never diagnose "corrupted files" from a shell read alone, and never `git restore`/overwrite working-tree files to "recover" from shell-reported corruption.
- `git` against the object DB (`git show HEAD:<file>`, `git log`, `git show :<file>`, `git cat-file`) is reliable; working-tree file-content reads through the shell mount are not.
- Any error found by a shell-side tool (linter, Godot, python) must be cross-checked against the real repo files before being reported as real.
- Do not bind-mount a host Windows directory onto container `/tmp` for Godot checks. The `/tmp` used by `godot_test_check.md` must be container-native Linux storage.
