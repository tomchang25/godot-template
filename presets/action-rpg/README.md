# action-rpg preset

`base` + this overlay = a Godot project for **real-time / spatial / many-entity**
games. The convention it adds is *distributed state*: logic and state live on entity
Component nodes, with a per-frame driver — no Store/System layer.

```
action-rpg/
  CLAUDE.md                       agent guide for this preset
  dev/standards/
    component_architecture.md     entity-as-composed-scene + components + loop
    project_structure.addendum.md
  overlay/                        copied on top of base by tools/compose.py
    common/gameplay/components/   Health, Hurtbox, Hitbox
    common/gameplay/entity/       Entity base
    global/autoloads/             node_pool.gd, world_state.gd
    game/example_arpg/            player, enemy, arena (combat slice)
    project.autoload.fragment.cfg
```

## Assemble & run

```
python tools/compose.py action-rpg
# → build/action-rpg/  (open this folder in Godot 4.6)
```

Boots into `arena_scene`. WASD / arrows move, Space attacks, Tab saves. Enemies spawn
on a timer and chase you; your attack damages their Hurtboxes; their contact Hitbox
damages you. Demonstrates component composition, a real-time driver, pooling, and
snapshot-at-save-point persistence.

These scenes are structural scaffolds — open them in Godot 4.6 to verify collision
layers and tune feel. See `CLAUDE.md` for the full convention.
