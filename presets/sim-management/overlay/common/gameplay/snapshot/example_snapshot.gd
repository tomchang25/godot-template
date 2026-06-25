# example_snapshot.gd
# Snapshot archetype skeleton: read-only output computed once, then discarded.
class_name ExampleSnapshot
extends RefCounted

var label: String = ""
var score: int = 0


static func create(entry: ExampleEntry) -> ExampleSnapshot:
	var snapshot := ExampleSnapshot.new()
	if entry != null and entry.data != null:
		snapshot.label = entry.data.display_name
		snapshot.score = ExampleService.score_entry(entry)
	return snapshot
