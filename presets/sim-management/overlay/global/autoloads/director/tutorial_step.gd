# tutorial_step.gd
# Tutorial step data object used by ScriptDirector and rendered by Director.
class_name TutorialStep
extends RefCounted

enum Kind { HINT, POPUP }
enum Advance { NEXT, SCENE_ENTERED, EVENT }

var kind: int = Kind.HINT
var anchor_id: String = ""
var text: String = ""
var advance: int = Advance.NEXT
var unlock_anchor: bool = false
var fallback_anchor_ids: Array[String] = []
var fallback_when_anchor_unrenderable: bool = false
var advance_event_id: StringName = &""
var advance_scene_id: String = ""
var blocks_input: bool = true


static func hint(step_text: String, target_anchor_id: String) -> TutorialStep:
	var step := TutorialStep.new()
	step.kind = Kind.HINT
	step.text = step_text
	step.anchor_id = target_anchor_id
	return step


static func popup(step_text: String) -> TutorialStep:
	var step := TutorialStep.new()
	step.kind = Kind.POPUP
	step.text = step_text
	return step


func unlock() -> TutorialStep:
	unlock_anchor = true
	return self


func on_event(event_id: StringName) -> TutorialStep:
	advance = Advance.EVENT
	advance_event_id = event_id
	return self


func on_scene(scene_id: String) -> TutorialStep:
	advance = Advance.SCENE_ENTERED
	advance_scene_id = scene_id
	return self


func no_block() -> TutorialStep:
	blocks_input = false
	return self


func with_fallback(anchor_ids: Array[String]) -> TutorialStep:
	fallback_anchor_ids = anchor_ids.duplicate()
	return self
