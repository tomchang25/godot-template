# game_manager.gd
# Central autoload for scene transitions and cross-scene payload hand-off.
# Register all navigable scenes in _SCENES, then navigate with go_to("key").
extends Node

## Scene registry — map of string key to PackedScene.
## Add your game scenes here when building out a new project.
const _SCENES: Dictionary = {
	"example": preload("res://game/example/example_scene.tscn"),
}

## Optional payload forwarded to the next scene via consume_payload().
var _pending_payload: Variant = null


func _ready() -> void:
	RegistryCoordinator.run_migrations()
	RegistryCoordinator.run_validation()
	SaveManager.load()
	SaveManager.run_validation()


## Navigate to a registered scene by key, optionally passing a payload.
func go_to(key: String, payload: Variant = null) -> void:
	_pending_payload = payload
	if not _SCENES.has(key):
		push_error("GameManager: no scene registered for key '%s'" % key)
		return
	get_tree().change_scene_to_packed(_SCENES[key])


## Retrieve and clear the pending payload (call once from the arriving scene).
func consume_payload() -> Variant:
	var p := _pending_payload
	_pending_payload = null
	return p
