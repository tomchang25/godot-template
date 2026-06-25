# Preset: action-rpg

A preset overlay for **real-time / spatial / many-entity** games — per-frame updates,
physics, overlap queries. It is the deliberate opposite of `sim-management`: state and
behaviour are **distributed onto entities as Component nodes**, not centralised in
Stores. It is `base` plus the overlay in this folder; assemble with
`tools/compose.py action-rpg`.

Read the base `CLAUDE.md` first — the four spines, registries, scene routing, and save
*contract* come from there unchanged. This preset supplies the one thing the base
omits: **where game logic lives** (here: on the entity).

## What this preset adds

- **Component architecture** (`dev/standards/component_architecture.md`). An entity is
  a composed scene: a body root (`CharacterBody2D`/`Area2D`/`Node2D`) with Component
  nodes mounted as children, each owning one capability and its state. No Store, no
  central mutation gateway — per-frame and spatial logic must sit on the thing in the
  world. This is idiomatic node composition, **not** a bolt-on ECS.
- **Component library** (`overlay/common/gameplay/components/`): `Health`, `Hurtbox`,
  `Hitbox`, each with `reset()` / `set_enabled()` pool-lifecycle hooks and signal-based
  communication.
- **Entity base** (`overlay/common/gameplay/entity/entity.gd`): wires the common
  lifecycle (locate Health, relay death, fan reset/enable to component children).
- **Real-time driver**: `arena_scene.gd` runs the per-frame / timed loop (spawn,
  target-assign, cull) that the individual entities should not.
- **Pooling** (`node_pool.gd`) and **snapshot persistence** (`world_state.gd`, a save
  provider that snapshots persistent entity state at save points rather than owning it
  during play).

## Reference slice (in `overlay/`)

```
common/gameplay/components/health.gd | hurtbox.gd | hitbox.gd
common/gameplay/entity/entity.gd
global/autoloads/node_pool.gd | world_state.gd
game/example_arpg/player.tscn | enemy.tscn | arena_scene.tscn  (+ .gd)
project.autoload.fragment.cfg   adds NodePool + WorldState; sets main scene
```

WASD/arrows to move, Space to attack, Tab to save, Esc to load. Enemies spawn on a timer (the
driver), chase the player (entity behaviour), and deal contact damage via their
Hitbox; the player's attack Hitbox damages enemy Hurtboxes.

## Autoload order (composed)

`EventBus → SettingsStore → ToastManager → AudioManager → ExampleRegistry → SaveManager →
ExampleState → SceneRouter → NodePool → WorldState → GameManager`

`WorldState` is a save provider, so it follows `SaveManager`. `GameManager` is last.

## Rules of thumb

- New capability → new Component in `common/gameplay/components/`, named for the
  capability, communicating via signals, with `reset()` + `set_enabled()`.
- Per-entity behaviour goes on the entity (`_physics_process`); cross-entity, batched,
  or spatial-management behaviour goes in a driver scene.
- Reserve a true ECS only for thousands-of-entities batch-per-frame cases; node
  composition is the default and is sufficient for an action-RPG.
