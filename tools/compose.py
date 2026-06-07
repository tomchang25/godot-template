#!/usr/bin/env python3
"""compose.py — assemble a runnable Godot project from base + one preset overlay.

A project is `base/` plus a single preset's `overlay/` copied on top, with the
preset's `project.autoload.fragment.cfg` merged into the composed `project.godot`.

Usage:
    python tools/compose.py <preset> [--out DIR]

    <preset>   sim-management | action-rpg  (any folder under presets/)
    --out DIR  output directory (default: build/<preset>)

The base encodes no "where does logic live" convention; each preset supplies one.
See the repo README.md for the three-layer model.
"""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BASE = REPO / "base"
PRESETS = REPO / "presets"

# Never copied from base into a composed project (regenerated or VCS/tooling).
IGNORE = shutil.ignore_patterns(
    ".godot", ".git", ".import", "__pycache__", "*.tmp", "build",
    ".opencode", ".claude", ".vscode", ".commitsage", "*.uid",
)

FRAGMENT_NAME = "project.autoload.fragment.cfg"


def parse_fragment(path: Path) -> dict[str, list[tuple[str, str]]]:
    """Parse a fragment cfg into {section: [(key, raw_value_line), ...]}.

    Comments (; ...) and blank lines are ignored. raw_value_line is the text after
    the first '=', kept verbatim so Godot-typed values survive untouched.
    """
    sections: dict[str, list[tuple[str, str]]] = {}
    current: str | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith(";"):
            continue
        if stripped.startswith("[") and stripped.endswith("]"):
            current = stripped[1:-1]
            sections.setdefault(current, [])
            continue
        if current is None or "=" not in line:
            continue
        key, value = line.split("=", 1)
        sections[current].append((key.strip(), value.rstrip("\n")))
    return sections


def merge_project_godot(project_path: Path, fragment: dict[str, list[tuple[str, str]]]) -> None:
    """Merge fragment sections into an existing project.godot, in place.

    - [autoload] entries are inserted immediately before the GameManager line (so
      providers stay after SaveManager and before GameManager). If absent, the
      autoload is appended to the [autoload] section.
    - Any other section's keys override (replace) a matching key= line, or are
      appended to that section if not present.
    """
    lines = project_path.read_text(encoding="utf-8").splitlines()

    # Map each section header to the line index range of its body.
    def section_bounds(name: str) -> tuple[int, int] | None:
        start = None
        for i, ln in enumerate(lines):
            if ln.strip() == f"[{name}]":
                start = i + 1
                break
        if start is None:
            return None
        end = len(lines)
        for j in range(start, len(lines)):
            s = lines[j].strip()
            if s.startswith("[") and s.endswith("]"):
                end = j
                break
        return start, end

    for section, entries in fragment.items():
        bounds = section_bounds(section)
        if bounds is None:
            # Section missing entirely — append it at end of file.
            lines.append("")
            lines.append(f"[{section}]")
            lines.append("")
            for key, value in entries:
                lines.append(f"{key}={value}")
            continue

        for key, value in entries:
            start, end = section_bounds(section)  # re-resolve; lines mutate
            new_line = f"{key}={value}"
            # Replace existing key in this section.
            replaced = False
            for k in range(start, end):
                if lines[k].split("=", 1)[0].strip() == key:
                    lines[k] = new_line
                    replaced = True
                    break
            if replaced:
                continue
            # Insert. For autoload, place before GameManager; else end of section.
            insert_at = end
            if section == "autoload":
                for k in range(start, end):
                    if lines[k].startswith("GameManager="):
                        insert_at = k
                        break
            lines.insert(insert_at, new_line)

    project_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def copy_overlay(overlay: Path, out: Path) -> int:
    """Copy every file under overlay/ into out/, except the fragment. Returns count."""
    count = 0
    for src in overlay.rglob("*"):
        if src.is_dir():
            continue
        if src.name == FRAGMENT_NAME:
            continue
        rel = src.relative_to(overlay)
        dest = out / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        count += 1
    return count


def main() -> int:
    ap = argparse.ArgumentParser(description="Assemble base + preset into a runnable project.")
    ap.add_argument("preset", help="preset name (folder under presets/)")
    ap.add_argument("--out", default=None, help="output dir (default: build/<preset>)")
    args = ap.parse_args()

    preset_dir = PRESETS / args.preset
    overlay = preset_dir / "overlay"
    if not overlay.is_dir():
        print(f"error: no overlay at {overlay}", file=sys.stderr)
        return 1
    if not BASE.is_dir():
        print(f"error: no base at {BASE}", file=sys.stderr)
        return 1

    out = Path(args.out) if args.out else REPO / "build" / args.preset
    out.mkdir(parents=True, exist_ok=True)

    # 1. base → out
    shutil.copytree(BASE, out, ignore=IGNORE, dirs_exist_ok=True)
    # 2. overlay → out (overwrites)
    n = copy_overlay(overlay, out)
    # 3. merge the autoload/application fragment into project.godot
    fragment_path = overlay / FRAGMENT_NAME
    if fragment_path.is_file():
        merge_project_godot(out / "project.godot", parse_fragment(fragment_path))

    print(f"composed '{args.preset}' -> {out}")
    print(f"  base copied, {n} overlay file(s) applied, project.godot merged")
    print(f"  open {out} in Godot 4.6 (run the data pipeline first if data/tres is empty)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
