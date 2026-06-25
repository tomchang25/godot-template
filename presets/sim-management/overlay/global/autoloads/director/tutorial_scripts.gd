# tutorial_scripts.gd
# Tutorial script catalog skeleton. Keep tutorial ids, steps, and triggers here.
class_name TutorialScripts
extends RefCounted

class TutorialOverrideSpec:
	var id: StringName
	var payload: Variant = null
	var release_event: StringName = &""

	static func whole(override_id: StringName, override_payload: Variant = true) -> TutorialOverrideSpec:
		var spec := TutorialOverrideSpec.new()
		spec.id = override_id
		spec.payload = override_payload
		return spec

class TutorialUnit:
	var id: String = ""
	var steps_resolver: Callable
	var trigger: Callable
	var once: bool = true
	var overrides: Array[TutorialOverrideSpec] = []

	static func until(override_id: StringName, event_id: StringName) -> TutorialOverrideSpec:
		var spec := TutorialOverrideSpec.whole(override_id)
		spec.release_event = event_id
		return spec


static func resolve_script(script_id: String) -> Array[TutorialStep]:
	match script_id:
		"example_intro":
			return example_intro_script()
		_:
			return []


static func known_script_ids() -> Array[String]:
	return ["example_intro"]


static func units() -> Array[TutorialUnit]:
	var unit := TutorialUnit.new()
	unit.id = "example_intro"
	unit.steps_resolver = Callable(TutorialScripts, "example_intro_script")
	unit.trigger = func(_scene_id: String, _ctx: Dictionary) -> bool: return false
	return [unit]


static func example_intro_script() -> Array[TutorialStep]:
	return [
		TutorialStep.popup("This is a tutorial skeleton."),
		TutorialStep.hint("This hint can target a registered anchor.", "example_anchor"),
	]


static func validate_anchors(_scene_id: String, _anchors: Dictionary) -> bool:
	return true
