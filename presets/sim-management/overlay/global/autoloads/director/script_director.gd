# script_director.gd
# Tutorial flow skeleton: active script, step index, and signal wiring.
extends Node

var active: bool = false

var _active_script_id: String = ""
var _active_script: Array[TutorialStep] = []
var _active_step_index: int = 0


func _ready() -> void:
	Director.scene_registered.connect(_on_scene_registered)
	Director.advance_requested.connect(_on_advance_requested)
	Director.tutorial_closed.connect(_on_tutorial_closed)
	EventBus.tutorial_event.connect(_on_tutorial_event)
	EventBus.save_runtime_reset.connect(reset_runtime)


## Starts a tutorial script by id.
func start_script(script_id: String) -> void:
	_active_script = TutorialScripts.resolve_script(script_id)
	if _active_script.is_empty():
		return
	_active_script_id = script_id
	_active_step_index = 0
	active = true
	Director.render_step(_active_script[_active_step_index])


## Stops the active script and marks it seen through the example System.
func stop_script() -> void:
	if not active:
		return
	var completed_id := _active_script_id
	active = false
	_active_script_id = ""
	_active_script = []
	_active_step_index = 0
	if completed_id != "" and has_node("/root/ExampleSystem"):
		ExampleSystem.mark_tutorial_seen(completed_id)
	Director.script_completed.emit(completed_id)


## Clears runtime-only tutorial flow state.
func reset_runtime() -> void:
	active = false
	_active_script_id = ""
	_active_script = []
	_active_step_index = 0
	GameplayOverride.clear_all()


func _on_scene_registered(_scene_id: String) -> void:
	pass


func _on_advance_requested() -> void:
	if not active:
		return
	_active_step_index += 1
	if _active_step_index >= _active_script.size():
		stop_script()
		return
	Director.render_step(_active_script[_active_step_index])


func _on_tutorial_closed() -> void:
	stop_script()


func _on_tutorial_event(event_id: StringName, _payload: Dictionary) -> void:
	if not active:
		return
	var step: TutorialStep = _active_script[_active_step_index]
	if step.advance == TutorialStep.Advance.EVENT and step.advance_event_id == event_id:
		_on_advance_requested()
