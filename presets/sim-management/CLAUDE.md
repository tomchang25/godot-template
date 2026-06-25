# Preset: sim-management

A preset overlay for **turn / idle / management / UI-heavy** games — data-driven,
state serialised, mutated in discrete steps, never per-frame. Covers auction/
management games (Lot & Haul) and idle games (a Melvor-like). It is `base` plus the
overlay in this folder; assemble with `tools/compose.py sim-management`.

Read the base `CLAUDE.md` first — the four spines, registries, scene routing, and
save *contract* all come from there unchanged. This preset adds **one thing the base
deliberately omits: where state lives and how it is mutated.**

## What this preset adds

- **Store / System model** (`dev/standards/store_manager.md`). The model layer is a
  set of **Stores** (serialisable, mutation-guarded state slices, `extends StoreBase`)
  held by a **System** autoload that is the sole mutation gateway, owns cross-domain
  transactions, and registers as the save provider. Supersedes the base Owner pattern.
- **Runtime-type archetypes** (`dev/standards/runtime_archetypes.md`):
  Store / Snapshot / Service / Entry, with `common/gameplay/{store,snapshot,service,entry}/`
  as the source of truth.
- **Block-scene data flow** (`dev/standards/block_scene_data_flow.md`): the
  `setup()` / `_apply()` injection convention (the node-source half stays in base).
- **Idle variant**: an idle game is this same preset plus a Tick System that advances
  time and re-runs pure Services over an elapsed interval — pure Stores + pure
  Services make offline resolution tractable. No separate preset.

## Reference slice (in `overlay/`)

```
common/gameplay/store/store_base.gd        StoreBase (save interface defaults)
common/gameplay/store/economy_store.gd     cash: getters + guarded mutators + save
common/gameplay/store/inventory_store.gd   collected ids + referential validate()
common/gameplay/store/progress_store.gd    tutorial seen flags + onboarding state
common/gameplay/entry/example_entry.gd     live instance of designer Data
common/gameplay/service/example_service.gd stateless helper functions
common/gameplay/snapshot/example_snapshot.gd
                                           computed read-only value object
global/autoloads/systems/example_system.gd
                                           holds both Stores, buy_entity() transaction,
                                           registers as save provider
global/autoloads/director/                 tutorial skeleton: Director, ScriptDirector,
                                           TutorialStep, TutorialTarget, events, overrides
game/example_sim/example_sim_scene.tscn    buy/save/load/reset demo via the System
project.autoload.fragment.cfg              adds ExampleSystem + tutorial skeleton autoloads; sets main scene
```

## Autoload order (composed)

`EventBus → SettingsStore → ToastManager → AudioManager → ExampleRegistry → SaveManager → ExampleState → SceneRouter → ExampleSystem → Director → ScriptDirector → GameplayOverride → GameManager`

`SaveManager` precedes every provider (providers call `register_provider` in
`_ready()`); `GameManager` is last and drives `load()` + `run_validation()`.

## Rules of thumb

- Scenes **read** Stores directly (`ExampleSystem.economy.cash`) but **never write**
  them — every mutation goes through a System transaction that ends in one
  `SaveManager.save()`.
- New domain → new Store in `common/gameplay/store/`, wired into a System's save
  fan-out. Follow the checklist in `store_manager.md`.
- Classify every new runtime type into one of the four archetypes before naming it.
