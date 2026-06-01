# save_manager.gd
# Persistence layer: section-based JSON save/load.
# Each system registers itself as a save section in its _ready(); SaveManager
# dispatches save() and load() to all registered sections.
#
# To add a new save section, create a Node (autoload) that implements:
#   func section_id() -> String      — unique key in the JSON file
#   func to_dict() -> Dictionary     — serialize state
#   func from_dict(data: Dictionary) — deserialize state
# Then call SaveManager.register_section(self) in its _ready().
extends Node

const SAVE_PATH := "user://save.json"
const SCHEMA_VERSION := 1

## Registered save sections. section_id -> Object with section_id/to_dict/from_dict.
var _sections: Dictionary = {}


## Register an object as a save section.
## Must implement: section_id() -> String, to_dict() -> Dictionary, from_dict(Dictionary).
func register_section(section: Object) -> void:
	_sections[section.section_id()] = section


func save() -> void:
	var out: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"sections": {}
	}
	for id: String in _sections:
		out["sections"][id] = _sections[id].to_dict()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open %s for writing" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(out, "\t"))


func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open %s for reading" % SAVE_PATH)
		return
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: invalid save data in %s" % SAVE_PATH)
		return
	# schema_version reserved for future migrations.
	var sections_data: Dictionary = parsed.get("sections", {})
	for id: String in sections_data:
		if _sections.has(id):
			_sections[id].from_dict(sections_data[id])
