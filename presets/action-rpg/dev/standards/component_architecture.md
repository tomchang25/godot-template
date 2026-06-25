# Component Architecture Standard

The "where does logic live" convention of the **action-rpg** preset — real-time,
spatial, many entities, per-frame updates. It is the deliberate opposite of the
sim-management preset's centralised Store/System model: here, **state and behaviour
are distributed onto the entity**, as Component nodes.

This convention is not in the neutral base. It replaces the sim preset's
Store/System standard and runtime-type archetypes.

## Entity = composed scene

An **entity** (player, enemy, projectile, pickup) is a scene whose root is a body
(`CharacterBody2D` / `Area2D` / `Node2D`) with **Component nodes mounted as children**.
The entity root holds almost no logic; each Component owns one capability.

```
Player (CharacterBody2D)        ← entity root: movement + wiring only
├── Sprite2D
├── CollisionShape2D
├── Health (Node)               ← component: hp, take_damage(), died
├── Hurtbox (Area2D)            ← component: receives hits, forwards to Health
└── Hitbox (Area2D)            ← component: deals damage on overlap
```

## No central mutation gateway

There is **no Store and no Manager owning entity state**. An entity's hp lives on its
own `Health` node and is mutated there. This is the right call for real-time games:
per-frame updates and spatial queries (overlaps, raycasts, nearest-target) must run on
the thing in the world, not marshalled through a central authority every frame.

(The save spine still exists — see *Persistence* below — but it reads/writes a
snapshot of entity state at save points, it does not gate per-frame mutation.)

## On "ECS"

This is **not** a bolt-on ECS. In Godot, Node + Scene is already a composition system.
A Component is an idiomatic node (`Health extends Node`, `Hitbox extends Area2D`),
mounted in the `.tscn`, found by the entity via `@onready`/`find_child` or `@export`.
Reserve a true data-oriented ECS for thousands-of-entities batch-per-frame cases
(bullet hell, large-scale sim); an action-RPG does not reach that, and node
composition is both sufficient and idiomatic.

## Component contract

A Component is a node that:

1. Owns **one capability** and the state for it (`Health` owns hp; `Hitbox` owns its
   damage and overlap tracking).
2. Communicates **up and out via signals** (`Health.died`, `Hurtbox.got_hit`) — the
   entity or sibling components connect to them. Components avoid reaching into
   siblings directly; prefer `@export` wiring or an `_auto_wire()` from `owner` in
   `_ready()`.
3. Exposes a **lifecycle**: `reset()` (restore to spawn defaults — called on pool
   acquire) and `set_enabled(bool)` (cheap on/off without freeing — called on pool
   release). These let entities be pooled instead of freed (see *Pooling*).

```gdscript
class_name Health
extends Node

signal health_changed(current: float, maximum: float)
signal died

@export var max_health: float = 100.0
var _current: float

func _ready() -> void:
    _current = max_health

func take_damage(amount: float) -> void: ...
func reset() -> void:
    _current = max_health
```

## Real-time system loop

Cross-entity, per-frame behaviour (enemy steering, spawn directing, despawn culling)
lives in a **driver** node that runs `_physics_process(delta)` and iterates the
entities it manages. This is the action-rpg analogue of the sim preset's transaction
methods — except it runs every frame, not at discrete commit points.

Keep heavy per-frame work out of individual entities when a driver can batch it;
keep purely-local behaviour (this entity's movement from its own input) on the entity.

## Pooling (optional but supported)

Spawn-heavy entities (projectiles, hit numbers, common enemies) should be pooled, not
freed, to avoid per-frame instantiation spikes. A pool acquires a node and calls
`reset()`; on release it calls `set_enabled(false)` and parks the node. This is why
the Component lifecycle hooks exist. See `overlay/global/autoloads/node_pool.gd`.

## Persistence

Entities own their state, so the save provider for a real-time game serialises a
**snapshot** of the entities that must persist (player stats, position, world
progress) at save points — it does not own that state during play. Reference:
`overlay/global/autoloads/world_state.gd`, a provider that reads the player's `Health`
and position into the save and writes them back on load. The base save *contract*
(`to_dict`/`from_dict`/`validate` + `register_provider`) is unchanged.

## Naming & folders

- Component scripts: `common/gameplay/components/<capability>.gd`, `class_name` in
  PascalCase (`Health`, `Hitbox`, `Hurtbox`).
- Entity base + shared entity pieces: `common/gameplay/entity/`.
- Entity scenes and combat features: `game/<feature>/`.
- A Component is named for its capability, not its host (`Health`, never `PlayerHp`).
