# director.gd
# Tutorial presentation skeleton: anchors, prompts, and presentation signals only.
extends Node

signal scene_registered(scene_id: String)
signal advance_requested
signal tutorial_closed
signal offer_accepted(script_id: String)
signal offer_skipped(script_id: String)
signal script_completed(script_id: String)

var _current_scene_id: String = ""
var _anchors: Dictionary = {}


## Registers scene-level tutorial anchors. Anchor ids are semantic, not node paths.
func register_scene(scene_id: String, anchors: Dictionary = {}) -> void:
	_current_scene_id = scene_id
	_anchors = anchors.duplicate()
	scene_registered.emit(scene_id)


## Registers a transient anchor, such as a popup button.
func register_anchor(anchor_id: String, anchor: Control) -> void:
	_anchors[anchor_id] = anchor


## Unregisters a transient anchor.
func unregister_anchor(anchor_id: String) -> void:
	_anchors.erase(anchor_id)


## Returns the currently registered anchor, if any.
func get_anchor(anchor_id: String) -> Control:
	return _anchors.get(anchor_id, null)


## Presentation hook. Real projects render the overlay here.
func render_step(_step: TutorialStep) -> void:
	pass


## Clears visible tutorial presentation without changing tutorial flow state.
func reset_tutorial_presentation() -> void:
	_anchors.clear()
	_current_scene_id = ""
