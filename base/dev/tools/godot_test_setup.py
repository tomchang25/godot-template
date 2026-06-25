"""
godot_test_setup.py - Prepare a safe /tmp snapshot for Godot test runs.

This helper is intentionally setup-only. It creates the sandbox-local project
copy, copies the gitignored Godot binary directory, verifies PyYAML is available,
and regenerates generated project data from the snapshot.
"""

from __future__ import annotations

import argparse
import importlib.util
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


GODOT_BINARY_PATTERN = "Godot*_linux.x86_64"


def _log(message: str) -> None:
    print(message, file=sys.stderr)


def _run(args: list[str], cwd: Path, *, stdout=None) -> subprocess.CompletedProcess:
    return subprocess.run(args, cwd=cwd, text=True, stdout=stdout, stderr=sys.stderr)


def _git_output(args: list[str], cwd: Path) -> str:
    result = subprocess.run(args, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=sys.stderr)
    if result.returncode != 0:
        raise RuntimeError(f"Git command failed: {' '.join(args)}")
    return result.stdout.strip()


def _move_tree_contents(source: Path, target: Path) -> None:
    if not source.is_dir():
        raise RuntimeError(f"Project checkout path not found: {source}")
    for child in source.iterdir():
        shutil.move(str(child), target / child.name)


def _project_git_context(repo_root: Path) -> tuple[Path, str]:
    git_root = Path(_git_output(["git", "rev-parse", "--show-toplevel"], cwd=repo_root)).resolve()
    relative = repo_root.relative_to(git_root).as_posix()
    return git_root, relative


def _checkout_index(repo_root: Path, snapshot: Path) -> str:
    git_root, project_relative = _project_git_context(repo_root)
    checkout_root = Path(tempfile.mkdtemp(prefix="godot-template.index.", dir="/tmp"))
    prefix = f"{checkout_root}/"
    files = subprocess.run(
        ["git", "ls-files", "-z", "--", project_relative],
        cwd=git_root,
        stdout=subprocess.PIPE,
        stderr=sys.stderr,
    )
    if files.returncode != 0 or not files.stdout:
        raise RuntimeError(f"No tracked files found for project path: {repo_root}")

    result = subprocess.run(
        ["git", "checkout-index", "-z", "--stdin", f"--prefix={prefix}"],
        cwd=git_root,
        input=files.stdout,
        stdout=subprocess.DEVNULL,
        stderr=sys.stderr,
    )
    if result.returncode == 0:
        _move_tree_contents(checkout_root / project_relative, snapshot)
        shutil.rmtree(checkout_root, ignore_errors=True)
        return "index"

    _log("git checkout-index failed; falling back to git archive HEAD.")
    shutil.rmtree(checkout_root, ignore_errors=True)
    archive_root = Path(tempfile.mkdtemp(prefix="godot-template.archive.", dir="/tmp"))
    archive = subprocess.Popen(
        ["git", "archive", "HEAD", "--", project_relative],
        cwd=git_root,
        stdout=subprocess.PIPE,
        stderr=sys.stderr,
    )
    extract = subprocess.Popen(
        ["tar", "-x", "-C", str(archive_root)],
        cwd=git_root,
        stdin=archive.stdout,
        stderr=sys.stderr,
    )
    if archive.stdout is not None:
        archive.stdout.close()

    extract_status = extract.wait()
    archive_status = archive.wait()
    if archive_status != 0 or extract_status != 0:
        raise RuntimeError("Both git checkout-index and git archive HEAD failed.")
    _move_tree_contents(archive_root / project_relative, snapshot)
    shutil.rmtree(archive_root, ignore_errors=True)
    return "HEAD"


def _copy_godot_bin(repo_root: Path, snapshot: Path) -> Path:
    source = repo_root / "dev" / "tools" / "bin"
    if not source.is_dir():
        raise RuntimeError(f"Godot binary directory not found: {source}")

    target_parent = snapshot / "dev" / "tools"
    target_parent.mkdir(parents=True, exist_ok=True)
    target = target_parent / "bin"
    shutil.copytree(source, target, dirs_exist_ok=True)

    matches = sorted(target.glob(GODOT_BINARY_PATTERN))
    if not matches:
        raise RuntimeError(f"No Godot binary matching {GODOT_BINARY_PATTERN} in {target}")
    return matches[0]


def _require_yaml() -> None:
    if importlib.util.find_spec("yaml") is None:
        raise RuntimeError(
            "PyYAML is not installed for this Python. In node:22-bookworm, install "
            "it once with: apt-get update && apt-get install -y python3-yaml"
        )


def _run_python_tool(snapshot: Path, relative_script: str, *args: str) -> None:
    script = snapshot / relative_script
    result = _run(
        [sys.executable, str(script), *args],
        cwd=snapshot,
        stdout=sys.stderr,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Tool failed: {relative_script}")


def _generate_content(snapshot: Path) -> None:
    godot_root = str(snapshot)
    _run_python_tool(snapshot, "dev/tools/yaml_to_tres.py", "--godot-root", godot_root)
    _run_python_tool(
        snapshot,
        "dev/tools/render_sfx.py",
        "--dir",
        str(snapshot / "data" / "yaml" / "sfx"),
        "--godot-root",
        godot_root,
    )
    _run_python_tool(snapshot, "dev/tools/localization_yaml_to_csv.py", "--godot-root", godot_root)


def _print_env(snapshot: Path, source: str, godot_bin: Path) -> None:
    values = {
        "GT": str(snapshot),
        "GODOT_TEST_SNAPSHOT_SOURCE": source,
        "GODOT_BIN": str(godot_bin),
    }
    for key, value in values.items():
        print(f"export {key}={shlex.quote(value)}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Prepare a safe /tmp snapshot for Godot headless and unit tests."
    )
    parser.add_argument(
        "--repo-root",
        default=os.getcwd(),
        help="Repository root to snapshot. Defaults to the current directory.",
    )
    parser.add_argument(
        "--env",
        action="store_true",
        help="Print shell exports for GT, GODOT_TEST_SNAPSHOT_SOURCE, and GODOT_BIN.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    snapshot = Path(tempfile.mkdtemp(prefix="godot-template.", dir="/tmp"))

    try:
        _log(f"Snapshot: {snapshot}")
        source = _checkout_index(repo_root, snapshot)
        godot_bin = _copy_godot_bin(repo_root, snapshot)
        _require_yaml()
        _generate_content(snapshot)
    except Exception as exc:
        print(f"godot-test setup failed: {exc}", file=sys.stderr)
        return 1

    if args.env:
        _print_env(snapshot, source, godot_bin)
    else:
        print(snapshot)
        _log(f"Snapshot source: {source}")
        _log(f"Godot binary: {godot_bin}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
