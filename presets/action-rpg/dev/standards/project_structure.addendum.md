# Project Structure — action-rpg addendum

Adds to the base `project_structure.md`. The action-rpg preset replaces the sim
preset's `common/gameplay/{store,snapshot,service,entry}` archetype tree with an
entity/component layout.

## `common/gameplay/` — components & entities

```
common/gameplay/
  components/   → Component nodes, one capability each (Health, Hurtbox, Hitbox, …)
  entity/       → Entity base + shared entity pieces (entity.gd)
```

A Component is named for its capability (`Health`), never its host (`PlayerHp`), and
is mounted in an entity `.tscn`, not added from code at runtime.

## `global/autoloads/` — real-time infra

```
global/autoloads/
  node_pool.gd    → acquire/release spawn pool (reset()/set_enabled() lifecycle)
  world_state.gd  → save provider: snapshots persistent entity state at save points
```

## `game/<feature>/` — entity scenes & drivers

```
game/
  example_arpg/
    player.tscn / player.gd    → composed entity: body + component children
    enemy.tscn / enemy.gd      → composed entity, pooled
    arena_scene.tscn / .gd     → the real-time _physics_process / timed driver
```

Entity scenes are composed scenes (a body root with Component children). Cross-entity,
per-frame behaviour lives in a driver scene (`arena_scene.gd`), not on the entities.
There is no Store/System layer — entity state lives on the entity's components.
