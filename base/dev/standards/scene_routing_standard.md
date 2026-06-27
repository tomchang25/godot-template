# Scene Routing Standard

This document defines how scene transitions are registered and executed.

---

# 1. Ownership

`SceneRouter` is the only owner of scene transitions. `GameManager` owns boot orchestration only and must not hold scene tables, payload hand-off, or direct gameplay navigation APIs.

Use `SceneRouter.go_to(route_key, payload)` from scenes and systems. Use `SceneRouter.consume_payload()` once from the arriving scene when a transition carries data.

---

# 2. Route Registration

Routes live in the `SceneRegistry` resource embedded in `global/autoloads/scene_router/scene_router.tscn`.

Each route key maps to one `PackedScene`. Keep keys stable and semantic: `hub`, `inventory`, `combat_arena`, `example_sim`. Do not encode file paths at call sites.

The base registry must always include:

- `start_page` — the project entry menu.
- The default gameplay route named by `SceneRegistry.default_route`.
- `test_runner` — the unit-test route used by `--test-unit`.

Preset overlays may replace `scene_router.tscn` to change the default route or add preset-specific routes. Do not replace `scene_router.gd` unless the router behavior itself changes for every project using that overlay.

---

# 3. Navigation API

Preferred calls:

```gdscript
SceneRouter.go_to(&"inventory")
SceneRouter.go_to(&"detail", {"entity_id": entity.entity_id})
SceneRouter.go_to_default()
SceneRouter.go_to_start_page()
```

Payloads are one-shot hand-offs. The arriving scene owns consumption:

```gdscript
func _ready() -> void:
    var payload: Variant = SceneRouter.consume_payload()
    if payload is Dictionary:
        _load_payload(payload)
```

Do not store long-lived gameplay state in navigation payloads. Payloads are for transition context, not persistence.

---

# 4. Forbidden Patterns

- Do not call `get_tree().change_scene_to_file()` or `get_tree().change_scene_to_packed()` from gameplay scenes except for isolated testbeds that intentionally bypass project routing.
- Do not add `GameManager.go_to(...)` or reintroduce scene tables into `GameManager`.
- Do not preload navigable scenes at call sites just to transition to them.
- Do not keep route keys duplicated in constants next to the caller unless that caller owns a public API around that route.

---

# 5. Review Checklist

- New navigable scene is registered in `scene_router.tscn`.
- Caller uses `SceneRouter.go_to(...)` or a narrow project-specific wrapper on top of it.
- If payload is used, the arriving scene consumes it once and handles missing/invalid payload gracefully.
- Preset-specific default scene changes happen by overlaying `scene_router.tscn`, not by overriding `run/main_scene`.
