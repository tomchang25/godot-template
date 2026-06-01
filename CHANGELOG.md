# Changelog

Append-only record of shipped work. This is the project's permanent "done" history.

**Why this file exists:** it is the single home for "what got built." Because it is append-only — you only ever add entries, never reconcile them against current code — it cannot go stale. This is what lets every other tracking surface stay forward-only: `systems/` describes the system as it *is* (present tense, no Done lists) and `TODO.md` holds only open work (`## Active` in-flight flows, `Plan`/`Chore`/`Bug`, and `## Draft` concepts), with multi-step flows detailed in `dev/docs/plans/` files. When a phase ships, append one entry here, then cut that phase from its plan file; when a whole flow ships, also delete its `TODO.md` line.

---

## [unreleased]

### template extracted from lot-and-haul
- Removed Storage Wars game content (scenes, runtime types, clue/item/car/auction systems)
- Retained four spines: data pipeline, boot orchestration, section-based save, go_to() scene routing
- Added `ResourceRegistry` base class; all per-type registries now extend it
- Rewrote `SaveManager` as section-registration dispatch (removes hard-coded game fields)
- Rewrote `GameManager` with `_SCENES` const dict + `go_to(key, payload)`
- Added example vertical slice: `ExampleEntityData` → YAML → tres → `ExampleRegistry` → `ExampleSaveSection` → `example_scene`
- Updated `dev/tools` pipeline: only `example_entity` spec remains; prompts rewritten as "how to add an entity" guide
- Reset `TODO.md` / `CHANGELOG.md` to template initial state
