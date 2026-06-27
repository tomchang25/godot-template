# Godot Template — base + presets

A three-layer Godot 4.6 template. One **paradigm-neutral base** (the four spines and
cross-cutting standards), plus thin **presets** that each encode one "where does game
logic live" convention. A project is assembled as **base + one preset overlay**.

```
godot-template/
  base/                      paradigm-neutral Godot project (the four spines)
  presets/
    sim-management/          turn / idle / management / UI-heavy  (Lot & Haul shape)
    action-rpg/              real-time / spatial / many-entity    (Arise shape)
  tools/compose.py           base + preset  ->  build/<preset>/  (runnable project)
  build/                     composed projects (generated)
```

## The dividing line

The split is **not** "MVC vs ECS" — it is **turn/idle vs real-time**:

| Paradigm | Where logic lives | Preset |
| --- | --- | --- |
| Turn / idle / management / UI-heavy | Centralised in Managers + Stores + pure Services | `sim-management` |
| Real-time / action / many entities / spatial | Distributed onto entities as Component nodes | `action-rpg` |

Manager-centric and entity-distributed logic answer "where does logic live" with
opposite rules, so they cannot share one standards set. The **base** deliberately
answers it *nowhere* — a reader cannot tell from the base whether the game is
turn-based or real-time. That neutrality is the asset; each preset adds exactly one
convention on top, without copying any spine.

## The base (what's shared)

- **Four spines**: data pipeline (YAML→tres→registry), boot orchestration
  (autoloaded registries), save system (thin provider-based `SaveManager`), scene
  routing (`SceneRouter`).
- **Neutral standards**: naming, project structure (skeleton), registries, lint
  enforcement, plan/spec standards, commits, and the block-scene **node-source rule**.
- The save layer ships only the **contract** (`to_dict`/`from_dict`/`validate` +
  `register_provider`). *How* state is organised across domains is a preset decision.

See `base/CLAUDE.md`.

## The presets (what differs)

**`sim-management`** — a Store/System model layer: serialisable, mutation-guarded
**Stores** held by a **Manager** that is the sole mutation gateway and the save
provider; the Store/Snapshot/Service/Entry archetype taxonomy; the
`setup()`/`_apply()` block-scene data-flow convention. The idle variant is the same
preset plus a tick/offline-resolution driver. See `presets/sim-management/CLAUDE.md`.

**`action-rpg`** — entity-as-composed-scene with logic on **Component nodes**
(`Health`, `Hurtbox`, `Hitbox`), a real-time `_physics_process` driver, pooling, and
snapshot-at-save-point persistence. Idiomatic node composition, not a bolt-on ECS.
See `presets/action-rpg/CLAUDE.md`.

## Assemble a project

```
python tools/compose.py sim-management   # -> build/sim-management/
python tools/compose.py action-rpg       # -> build/action-rpg/
```

Open the composed `build/<preset>/` folder in Godot 4.6. If `data/tres/` is empty
(it's gitignored), run the data pipeline first:
`python dev/tools/yaml_to_tres.py` inside the composed project.

A spine fix is made once in `base/` and both presets inherit it on the next compose.

## Design rationale

The full plan and the reasoning behind the split (including the supersession of the
base Owner pattern by the Store/System model) live in
`base/dev/docs/plans/template_base_and_presets.md`.
