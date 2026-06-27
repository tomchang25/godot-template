# Scene Router Usage

Use this when adding or changing scene navigation.

## Add a route

1. Add the target scene as an `ext_resource` in `global/autoloads/scene_router/scene_router.tscn` or the preset overlay's replacement file.
2. Add a stable key to the embedded `SceneRegistry.routes` dictionary.
3. Navigate with `SceneRouter.go_to(&"route_key")`.
4. If this is the Start button target, set `SceneRegistry.default_route` to the new key.

## Pass context

```gdscript
SceneRouter.go_to(&"detail", {"entity_id": entity.entity_id})
```

In the arriving scene:

```gdscript
var payload: Variant = SceneRouter.consume_payload()
if payload is Dictionary:
    var entity_id := String(payload.get("entity_id", ""))
```

Payloads are transition context only. Save durable state through the project's save owner.

## Avoid

- `GameManager.go_to(...)`
- Direct `get_tree().change_scene_*()` from normal game screens
- Preloading scene files at each caller
