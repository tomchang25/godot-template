# Project Structure — sim-management addendum

Adds to the base `project_structure.md`. Only the deltas the preset introduces are
listed here; everything else follows the base.

## `common/gameplay/` — runtime type archetypes

The preset introduces a `gameplay/` tree under `common/`, partitioned by the four
runtime-type archetypes. The subfolder **is** the archetype (see
`runtime_archetypes.md`):

```
common/gameplay/
  store/      → StoreBase + domain Stores (System-held, serialised state)
  snapshot/   → read-only value objects (DaySummary, RunResult), computed then dropped
  service/    → stateless pure-math helpers (SellMath, …)
  entry/      → live instances of designer Data (ItemEntry wrapping ItemData)
```

## `global/autoloads/systems/` — orchestration layer

```
global/autoloads/systems/
  example_system.gd   → reference System: holds Stores, owns transactions,
                        registers as the save provider
```

A small game has one System; split by phase as it grows (e.g. a hub System and a
run System), each holding its own Stores and registering as its own provider.

## `global/autoloads/director/` — tutorial skeleton

```
global/autoloads/director/
  director.gd            → presentation API and anchor registry
  script_director.gd     → tutorial flow API and step index
  gameplay_override.gd   → runtime-only override store
  tutorial_step.gd       → step data object and fluent helpers
  tutorial_target.gd     → optional Control highlight metadata
  tutorial_events.gd     → semantic tutorial event ids
  tutorial_scripts.gd    → script catalog skeleton
```

## `game/<feature>/` — block scenes

Feature scenes follow the base node-source rule plus the
`setup()` / `_apply()` data-flow convention (`block_scene_data_flow.md`).

```
game/
  example_sim/   → reference scene wiring Store reads + System transactions + save
```
