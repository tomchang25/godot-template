# progress_store.gd
# Progress Store skeleton: tutorial seen flags and onboarding state.
class_name ProgressStore
extends StoreBase

var _tutorial_seen: Dictionary = {}
var _onboarding_pending: bool = true

var tutorial_seen: Dictionary:
	get:
		return _tutorial_seen.duplicate(true)

var onboarding_pending: bool:
	get:
		return _onboarding_pending


## Returns true when [param tutorial_id] has already completed.
func has_seen_tutorial(tutorial_id: String) -> bool:
	return bool(_tutorial_seen.get(tutorial_id, false))


## Marks [param tutorial_id] as completed.
func mark_tutorial_seen(tutorial_id: String) -> void:
	if tutorial_id.is_empty():
		return
	_tutorial_seen[tutorial_id] = true


## Ends onboarding for this save.
func complete_onboarding() -> void:
	_onboarding_pending = false


func section_id() -> String:
	return "progress"


func to_dict() -> Dictionary:
	return {
		"_version": _store_version(),
		"tutorial_seen": _tutorial_seen.duplicate(true),
		"onboarding_pending": _onboarding_pending,
	}


func from_dict(data: Dictionary) -> void:
	var version: int = int(data.get("_version", 1))
	data = _apply_migrations(data, version)
	_tutorial_seen = {}
	if data.get("tutorial_seen") is Dictionary:
		_tutorial_seen = data["tutorial_seen"].duplicate(true)
	_onboarding_pending = bool(data.get("onboarding_pending", _onboarding_pending))
