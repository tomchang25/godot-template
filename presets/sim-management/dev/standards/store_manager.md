# Store / Manager Standard

The model-layer convention of the **sim-management** preset. It supersedes the
base's monolithic Owner pattern for turn/idle/management games: it splits the
*model* (Store — serialisable, mutation-guarded state) from *orchestration*
(Manager — transactions, cross-domain coordination, the save point).

This convention is **not** part of the neutral base. The base ships only the save
*contract* (`to_dict`/`from_dict`/`validate` + `SaveManager.register_provider`);
this standard decides who implements it and how state is grouped.

## The two roles

### Store — the Model

A **Store** owns one domain's live fields and is the only thing that may write
them. It extends `StoreBase` (a `RefCounted`) and lives in
`common/gameplay/store/`.

1. **State** — private backing fields (`_cash`), exposed read-only via getters
   (`var cash: int: get: return _cash`). No external setter ⇒ no external write path.
2. **Operations** — the only write path. Mutators guard their own invariants
   (`spend()` refuses to go negative and returns `false`).
3. **Serialize** — `section_id()`, `to_dict()` (include `"_version"`), `from_dict()`.
4. **Migrate** — per-store field migration via `_apply_migrations(data, from_version)`.
5. **Validate** — referential integrity of restored state; drop unresolved ids with
   `push_warning`, never fault.

A Store has **no reference to its Manager, to scenes, or to other Stores**. It is a
pure, testable state slice. Persisting Stores override all four save methods;
session-scoped Stores (cleared each run, never saved) override none.

Reference: `common/gameplay/store/economy_store.gd`, `inventory_store.gd`,
`store_base.gd`.

### Manager — the orchestration

A **Manager** is an autoload that holds one or more Stores as plain public fields,
and is the **sole mutation gateway** to them. It lives in
`global/autoload/managers/`.

- Holds Stores: `var economy: EconomyStore` — scenes read `Manager.economy.cash`
  directly, but never write a Store.
- Owns **transactions** — a single method that may touch several Stores and then
  calls `SaveManager.save()` exactly once at the commit point (e.g. `buy_entity()`
  spends cash *and* adds to inventory, saving once).
- Is the save **provider**: `SaveManager.register_provider(self)` in `_ready()`,
  and `to_dict`/`from_dict`/`validate` fan out across its Stores.

Reference: `global/autoload/managers/game_state_manager.gd`.

## Why the split (vs the base Owner)

The base Owner fused model and orchestration in one autoload per domain. For a
sim/management game that grows cross-domain transactions ("end the day" touches
economy + storage + progress), that fusion forces either a god-Owner or a tangle
of Owner-to-Owner calls. Splitting gives:

- a **model layer** (Stores) that is serialisable and unit-testable without the tree;
- an **orchestration layer** (Manager) that owns multi-Store transactions and the
  single save point;
- a clean path to the **idle variant** — pure Stores advanced by pure Services let
  offline resolution re-run the same math over an elapsed interval.

## Direct call vs event (cross-manager)

When one Manager's correctness depends on another's result, **direct call** and gate
on the return (`if not economy.spend(cost): return false` — a failed spend rolls the
transaction back). When the caller does not care about the outcome, emit an
**EventBus** signal (broadcast `example_entity_collected` so other systems can react;
the purchase is correct regardless of who listens). Test: *"if the other side fails
or doesn't exist, do I roll back?"* Yes → direct call. No → event.

## Boundaries — unchanged from the base

| Concern | Lives in |
| --- | --- |
| Whole-file / `schema_version` migration (move a key between sections) | `SaveManager._migrate_schema()` |
| Per-store field migration (legacy field shapes in one section) | the Store's `_apply_migrations()` |
| Restored-save validation (live ids resolve) | the Store's `validate()` |
| Authored-content validation (designer `.tres` well-formed) | the Registry's `validate()` (must not read live state) |

## `from_dict` order (per Store)

```gdscript
func from_dict(data: Dictionary) -> void:
    var version: int = int(data.get("_version", 1))
    data = _apply_migrations(data, version)   # 1. legacy shapes → current
    _cash = int(data.get("cash", _cash))      # 2. read fields
# 3. referential validation runs later, in validate()
```

## Checklist for a new domain

1. Store script at `common/gameplay/store/<domain>_store.gd`, `extends StoreBase`.
2. Private fields + read-only getters. Mutators are the only write path and guard
   invariants.
3. `section_id()`, `to_dict()` (with `"_version"`), `from_dict()` (migrate → read),
   `validate()` (drop unresolved ids with `push_warning`).
4. The owning Manager `.new()`s the Store in `_ready()` and adds it to its
   `to_dict`/`from_dict`/`validate` fan-out.
5. Mutations to the Store happen **only** inside Manager transaction methods, each
   ending in a single `SaveManager.save()` at its commit point.
6. No Store ↔ Store references; no Store → scene references.
