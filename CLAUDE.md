# Godot Template — repo guide (three layers)

This repo is a three-layer Godot 4.6 template: a paradigm-neutral **base** plus thin
**preset** overlays. Read `README.md` for the model. Each layer has its own `CLAUDE.md`
— **work inside the layer you're editing and follow that layer's guide.**

```
base/                      neutral Godot project — the four spines.   guide: base/CLAUDE.md
presets/sim-management/    Store/System (turn/idle/UI).  guide: presets/sim-management/CLAUDE.md
presets/action-rpg/        Components (real-time).        guide: presets/action-rpg/CLAUDE.md
tools/compose.py           base + preset -> build/<preset>/
```

## Where to put a change

- A fix to a **spine** (data pipeline, boot, save coordinator, scene routing) or a
  neutral standard → `base/`. Both presets inherit it on the next compose. **Never**
  add a "where logic lives" convention to the base — that's what breaks the model.
- A change to the **Store/System** model, archetype taxonomy, or `setup()`/`_apply()`
  convention → `presets/sim-management/`.
- A change to **components**, the real-time loop, pooling, or entity layout →
  `presets/action-rpg/`.

## Overlay mechanics

A preset is `base/` with `presets/<preset>/overlay/` copied on top, then
`project.autoload.fragment.cfg` merged into `project.godot` by `tools/compose.py`.
Overlay files mirror the in-project path (`overlay/common/...` lands at
`res://common/...`). Author preset code under `overlay/`; author preset docs/standards
under the preset's `dev/standards/`.

## Sandbox / environment note

Inherited from the base: the sandboxed shell can report **phantom file corruption** and
may **block deletes/renames** when files are open in the Godot editor. The Read/Edit
file tools are authoritative; prefer them over shell reads. Don't `git restore` to
"recover" from a shell-only reading. If a delete fails with "Operation not permitted,"
a process (often the editor) holds the file — close it and retry.
