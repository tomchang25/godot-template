# example_entry.gd
# Entry archetype skeleton: one live mutable instance of designer data.
class_name ExampleEntry
extends RefCounted

var id: int = -1
var data: ExampleEntityData = null
var count: int = 0


## Creates an entry for [param entity_data] with runtime-owned mutable state.
static func create(entity_data: ExampleEntityData, entry_id: int) -> ExampleEntry:
	var entry := ExampleEntry.new()
	entry.id = entry_id
	entry.data = entity_data
	return entry


## Restores an entry from save data. String ids stay at this boundary.
static func from_dict(saved: Dictionary) -> ExampleEntry:
	var entry := ExampleEntry.new()
	entry.id = int(saved.get("id", -1))
	entry.count = int(saved.get("count", 0))
	var entity_id: String = saved.get("entity_id", "")
	if not entity_id.is_empty():
		entry.data = ExampleRegistry.get_example_by_id(entity_id)
	return entry


## Serializes this entry. Resource references become ids at the save boundary.
func to_dict() -> Dictionary:
	return {
		"id": id,
		"entity_id": data.entity_id if data != null else "",
		"count": count,
	}


## Mutator guarded by the owning System.
func add_count(amount: int) -> bool:
	if amount < 0:
		return false
	count += amount
	return true
