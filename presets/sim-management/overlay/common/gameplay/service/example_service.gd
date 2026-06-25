# example_service.gd
# Service archetype skeleton: stateless helper functions over explicit inputs.
class_name ExampleService
extends RefCounted


## Computes a display score without mutating Entries, Stores, or Resources.
static func score_entry(entry: ExampleEntry) -> int:
	if entry == null or entry.data == null:
		return 0
	return entry.data.value * maxi(entry.count, 1)
