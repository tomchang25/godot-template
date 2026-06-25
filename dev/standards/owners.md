# Owner Standard

Conventions for domain Owners — the unit of persistent runtime state in this project. One page. Grounded in the shape of the save system we have, not speculation.

## What an Owner is

An **Owner** is the single authority for one domain (economy, garage, storage, …). It unifies four responsibilities for that domain in one object:

1. **State** — holds the domain's live runtime fields. Nothing else owns or mutates them.
2. **Serialize** — implements the save-section contract: `section_id()`, `to_dict()`, `from_dict()`.
3. **Validate** — sanitizes its own restored state: ids that no longer resolve are dropped with `push_warning`, never a fault.
4. **Migrate** — maps its own legacy save shapes (renamed/removed fields) onto the current ones.

The reference implementation is `global/autoloads/example_owner.gd`.

### Owner vs. "save section"

A save *section* is the **contract** (`section_id`/`to_dict`/`from_dict`) and the slot a domain occupies in the save file. An Owner is the **object** that owns the domain and fills that contract. They are not alternatives — the Owner *is* the section.

The anti-pattern this standard exists to prevent is a section object that holds no state and only serializes another object's fields (e.g. a `FooSaveSection` that reads/writes `Foo.bar`). That splits one domain across two files and lets the "real" owner grow into a god-object. **If a thing serializes a domain's state, it must also own that state.**

## Boundaries — what an Owner does NOT do

Two responsibilities look like they belong to an Owner but don't, because the Owner lacks the necessary view:

| Concern | Lives in | Why not the Owner |
| --- | --- | --- |
| Cross-section / `schema_version` migration (move a key between sections, rename a section) | `SaveManager._migrate_schema()` | Needs the whole-file view; an Owner sees only its own section payload |
| Authored-content validation (do designer `.tres` files reference valid ids) | `Registry.validate()` | It's about static authored data, not save state — and `validate()` **must not read live/save state** |

These two axes are easy to conflate. The rule:

- **Owner** validates *restored save state* (live ids resolve) and migrates *its own field shapes*.
- **Registry** validates *authored content* and never touches live state.
- **SaveManager** migrates the *file as a whole* across schema versions.

## File layout

| Thing | Location |
| --- | --- |
| Script | `global/autoloads/<domain>_owner.gd` |
| Class name in save file | `section_id()` returns `"<domain>"` |
| Autoload registration | `project.godot`, after registries it reads, before `SaveManager` |
| Self-registration | `SaveManager.register_section(self)` in `_ready()` |

## `from_dict` order

`from_dict` runs three steps, in this order — the order is load-bearing:

```gdscript
func from_dict(data: Dictionary) -> void:
    data = _migrate(data)      # 1. legacy shapes → current shape
    # 2. read fields off the (now current-shape) data
    # 3. validate referential integrity — drop unresolved ids with push_warning
```

Validation runs *after* reading, against the registries, so it depends on those registries already being loaded. That holds because every registry autoloads before the Owner, and the Owner autoloads before `SaveManager`, whose `load()` (which calls `from_dict`) fires last from `GameManager._ready()`.

## Structural default: one autoload Owner per domain

The default shape is **one domain = one autoload Owner** that self-registers. Simple, independent, discoverable.

Introduce a **coordinator** (a node holding several `RefCounted` Owners) only when you have genuine cross-domain *atomic transactions* — one operation that must mutate several domains together (e.g. "end the day" touching cash, storage, and progress at once). The coordinator owns the transactions; each Owner still owns its own state and section. Do not reach for a coordinator (or proxy properties over Owners) just to group domains — that machinery is the escape hatch for a god-object you don't have yet.

## Checklist for a new Owner

1. Script at `global/autoloads/<domain>_owner.gd`, header comment lists the four responsibilities.
2. Live fields as `var`s with `##` docs. This Owner is the only writer.
3. `section_id()` returns a unique `"<domain>"` key.
4. `to_dict()` serializes; `from_dict()` does migrate → read → validate.
5. Drop unresolved ids on load with `push_warning`, never `push_error` / fault.
6. Per-domain field migration in a `_migrate(data)` helper. No cross-section logic here.
7. Autoload line in `project.godot`, before `SaveManager` (and after any registry `from_dict` reads).
8. No separate save-section adapter. No proxy layer unless a coordinator demands it.
