# sim-management preset

`base` + this overlay = a Godot project for **turn / idle / management / UI-heavy**
games. The convention it adds is *centralised state*: a Store/Manager model layer on
top of the base save contract.

```
sim-management/
  CLAUDE.md                      agent guide for this preset
  dev/standards/
    store_manager.md             the model-layer standard (supersedes base Owner)
    runtime_archetypes.md        Store / Snapshot / Service / Instance taxonomy
    block_scene_data_flow.md     setup() / _apply() data injection
    project_structure.addendum.md
  overlay/                       copied on top of base by tools/compose.py
    common/gameplay/{store,snapshot,service,instance}/
    global/autoload/managers/game_state_manager.gd
    game/example_sim/
    project.autoload.fragment.cfg
```

## Assemble & run

```
python tools/compose.py sim-management
# → build/sim-management/  (open this folder in Godot 4.6)
```

The composed project boots into `example_sim_scene`: pick an entity to buy (spends
cash via `EconomyStore`, adds it via `InventoryStore`, in one `GameStateManager`
transaction), then Save / Load / Reset to exercise the provider-based save system.

See `CLAUDE.md` for the full convention.
