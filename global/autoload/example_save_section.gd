# example_save_section.gd
# Autoload that persists example game state: collected entity ids and score.
# Registers itself with SaveManager as a save section.
# Template starter — duplicate this pattern for each system that needs persistence.
extends Node

## Entity ids the player has collected.
var collected_ids: Array[String] = []

## Running total score.
var score: int = 0


func _ready() -> void:
	SaveManager.register_section(self)


## Unique key for this section in the JSON save file.
func section_id() -> String:
	return "example"


func to_dict() -> Dictionary:
	return {
		"collected_ids": collected_ids.duplicate(),
		"score": score,
	}


func from_dict(data: Dictionary) -> void:
	collected_ids = []
	if data.get("collected_ids") is Array:
		for id: Variant in data["collected_ids"]:
			if id is String:
				collected_ids.append(id)
	var raw_score: Variant = data.get("score", 0)
	score = int(raw_score) if raw_score is float or raw_score is int else 0
