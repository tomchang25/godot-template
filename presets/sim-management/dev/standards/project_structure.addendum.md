# Project Structure — sim-management addendum

Adds to the base `project_structure.md`. Only the deltas the preset introduces are
listed here; everything else follows the base.

## `common/gameplay/` — runtime type archetypes

The preset introduces a `gameplay/` tree under `common/`, partitioned by the four
runtime-type archetypes. The subfolder **is** the archetype (see
`runtime_archetypes.md`):

```
common/gameplay/
  store/      → StoreBase + domain Stores (Manager-held, serialised state)
  snapshot/   → read-only value objects (DaySummary, RunResult), computed then dropped
  service/    → stateless pure-math helpers (SellMath, …)
  instance/   → live instances of designer Data (ItemEntry wrapping ItemData)
```

## `global/autoload/managers/` — orchestration layer

```
global/autoload/managers/
  game_state_manager.gd   → reference Manager: holds Stores, owns transactions,
                            registers as the save provider
```

A small game has one Manager; split by phase as it grows (e.g. a hub Manager and a
run Manager), each holding its own Stores and registering as its own provider.

## `game/<feature>/` — block scenes

Feature scenes follow the base node-source rule plus the
`setup()` / `_apply()` data-flow convention (`block_scene_data_flow.md`).

```
game/
  example_sim/   → reference scene wiring Store reads + Manager transactions + save
```
