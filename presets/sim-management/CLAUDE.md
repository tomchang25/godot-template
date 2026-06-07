# Preset: sim-management

A preset overlay for **turn / idle / management / UI-heavy** games — data-driven,
state serialised, mutated in discrete steps, never per-frame. Covers auction/
management games (Lot & Haul) and idle games (a Melvor-like). It is `base` plus the
overlay in this folder; assemble with `tools/compose.py sim-management`.

Read the base `CLAUDE.md` first — the four spines, registries, scene routing, and
save *contract* all come from there unchanged. This preset adds **one thing the base
deliberately omits: where state lives and how it is mutated.**

## What this preset adds

- **Store / Manager model** (`dev/standards/store_manager.md`). The model layer is a
  set of **Stores** (serialisable, mutation-guarded state slices, `extends StoreBase`)
  held by a **Manager** autoload that is the sole mutation gateway, owns cross-domain
  transactions, and registers as the save provider. Supersedes the base Owner pattern.
- **Runtime-type archetypes** (`dev/standards/runtime_archetypes.md`):
  Store / Snapshot / Service / Instance, with `common/gameplay/{store,snapshot,service,instance}/`
  as the source of truth.
- **Block-scene data flow** (`dev/standards/block_scene_data_flow.md`): the
  `setup()` / `_apply()` injection convention (the node-source half stays in base).
- **Idle variant**: an idle game is this same preset plus a Tick Manager that advances
  time and re-runs pure Services over an elapsed interval — pure Stores + pure
  Services make offline resolution tractable. No separate preset.

## Reference slice (in `overlay/`)

```
common/gameplay/store/store_base.gd        StoreBase (save interface defaults)
common/gameplay/store/economy_store.gd     cash: getters + guarded mutators + save
common/gameplay/store/inventory_store.gd   collected ids + referential validate()
global/autoload/managers/game_state_manager.gd
                                           holds both Stores, buy_entity() transaction,
                                           registers as save provider
game/example_sim/example_sim_scene.tscn    buy/save/load/reset demo via the Manager
project.autoload.fragment.cfg              adds GameStateManager; sets main scene
```

## Autoload order (composed)

`EventBus → AudioManager → RegistryCoordinator → ExampleRegistry → SaveManager →
ExampleState → GameStateManager → GameManager`

`SaveManager` precedes every provider (providers call `register_provider` in
`_ready()`); `GameManager` is last and drives `load()` + `run_validation()`.

## Rules of thumb

- Scenes **read** Stores directly (`GameStateManager.economy.cash`) but **never write**
  them — every mutation goes through a Manager transaction that ends in one
  `SaveManager.save()`.
- New domain → new Store in `common/gameplay/store/`, wired into a Manager's save
  fan-out. Follow the checklist in `store_manager.md`.
- Classify every new runtime type into one of the four archetypes before naming it.
