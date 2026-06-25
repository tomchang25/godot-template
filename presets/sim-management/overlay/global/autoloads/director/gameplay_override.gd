# gameplay_override.gd
# Runtime-only tutorial override store pushed by ScriptDirector and read by scenes.
extends Node

signal override_changed(override_id: StringName, active: bool, payload: Variant)

var _overrides: Dictionary = {}


## Returns true when [param override_id] is active.
func is_active(override_id: StringName) -> bool:
	return _overrides.has(override_id)


## Returns the override payload, or null when inactive.
func payload(override_id: StringName) -> Variant:
	return _overrides.get(override_id, null)


## Activates or replaces an override.
func set_override(override_id: StringName, value: Variant = true) -> void:
	_overrides[override_id] = value
	override_changed.emit(override_id, true, value)


## Deactivates one override.
func clear_override(override_id: StringName) -> void:
	if not _overrides.has(override_id):
		return
	_overrides.erase(override_id)
	override_changed.emit(override_id, false, null)


## Clears all runtime overrides.
func clear_all() -> void:
	for override_id: Variant in _overrides.keys():
		override_changed.emit(StringName(override_id), false, null)
	_overrides.clear()
