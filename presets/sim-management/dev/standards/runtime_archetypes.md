# Runtime Type Archetypes

Every runtime type under `common/gameplay/` is exactly one of four archetypes. The
**subfolder is the source of truth** for which one. This taxonomy is specific to the
sim-management paradigm (centralised, serialised, mutated in discrete steps) — it is
not in the neutral base, and the action-rpg preset replaces it with an
entity/component taxonomy.

Do not invent new suffixes or archetypes outside this set. If a new type doesn't
clearly fit, stop and ask before naming it.

| Archetype | Subfolder | What it is | Saves? | Mutable? |
| --- | --- | --- | --- | --- |
| **Store** | `store/` | System-held domain state container with invariant-guarding mutators | persisting Stores yes | yes (via mutators) |
| **Snapshot** | `snapshot/` | read-only value object, computed once then discarded (e.g. a `DaySummary`, a `RunResult`) | no | no |
| **Service** | `service/` | stateless pure-math helper (e.g. `SellMath`, a research-slot calculator) | no | no state |
| **Entry** | `entry/` | live instance of a designer `Data` — identity + mutable state + self-maintaining behaviour (e.g. an `ItemEntry` wrapping `ItemData`) | yes (inside a Store) | yes |

## Discriminator

Ask, in order:

1. **No state at all, just functions over inputs?** → Service.
2. **Read-only, computed once and thrown away?** → Snapshot.
3. **A saved, mutable instance of a designer `Data` resource?** → Entry.
4. **System-held, mutable, the domain's state container?** → Store.

## Notes

- **Snapshot vs Store**: a Snapshot is derived output (the result of a transaction,
  shown on a summary screen, then dropped). A Store is durable state. If you find
  yourself wanting to save a Snapshot, it's actually a Store.
- **Service vs Store**: a Service never holds state between calls. The moment a
  "helper" needs to remember something across calls, it's a Store.
- **Entry vs Data**: `Data` (under `data/definitions/`) is the designer-authored
  template, loaded from `.tres`. An Entry is one live, mutating copy the player
  owns. Entries are serialised as part of the Store that holds them — they don't
  register with `SaveManager` themselves.
- Pass **Resource refs / Entries**, not ids, across boundaries. String ids are for
  save/load only.
