# inventory_store.gd
# Inventory domain Store: the set of example-entity ids the player has collected.
# Reference Store showing referential-integrity validation — on load, ids that no
# longer resolve against ExampleRegistry are dropped with a warning rather than
# faulting the load. Held by ExampleSystem.
class_name InventoryStore
extends StoreBase

var _collected_ids: Array[String] = []

## Collected entity ids. Read-only externally — returns a copy so callers cannot
## mutate the backing array.
var collected_ids: Array[String]:
	get:
		return _collected_ids.duplicate()

# ══ Operations (the only write path) ══════════════════════════════════════════


## Returns true if [param id] is already collected.
func has_collected(id: String) -> bool:
	return _collected_ids.has(id)


## Adds [param id] to the collection if not already present. Returns true when it
## was newly added.
func collect(id: String) -> bool:
	if _collected_ids.has(id):
		return false
	_collected_ids.append(id)
	return true


## Empties the collection.
func clear() -> void:
	_collected_ids.clear()

# ══ Save contract ═════════════════════════════════════════════════════════════


func section_id() -> String:
	return "inventory"


func to_dict() -> Dictionary:
	return {"_version": _store_version(), "collected_ids": _collected_ids.duplicate()}


func from_dict(data: Dictionary) -> void:
	var version: int = int(data.get("_version", 1))
	data = _apply_migrations(data, version)
	_collected_ids = []
	if data.get("collected_ids") is Array:
		for id: Variant in data["collected_ids"]:
			if id is String:
				_collected_ids.append(id)


## Drops collected ids that no longer resolve against ExampleRegistry. Warns,
## never faults — a renamed or removed entity must not brick an old save.
func validate() -> bool:
	var kept: Array[String] = []
	for id: String in _collected_ids:
		if ExampleRegistry.get_example_by_id(id) == null:
			push_warning("InventoryStore: collected id '%s' not found — dropped" % id)
			continue
		kept.append(id)
	_collected_ids = kept
	return true
