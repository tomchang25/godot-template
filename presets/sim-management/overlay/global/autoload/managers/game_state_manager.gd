# game_state_manager.gd
# Reference Manager for the sim-management preset. Holds the domain Stores as
# plain public fields, is the SOLE mutation gateway for them, owns cross-domain
# transactions, and registers itself with SaveManager as a single provider that
# fans to_dict / from_dict / validate across its Stores.
#
# Scenes read state directly off the Stores (GameStateManager.economy.cash,
# GameStateManager.inventory.collected_ids) but never mutate them — every write
# goes through a method here, so invariants and the save point live in one place.
#
# Duplicate this shape per Manager. A small game may have one Manager; a larger
# one splits by phase (e.g. a hub Manager and a run Manager), each holding its
# own Stores. See dev/standards/store_manager.md.
extends Node

# ── Domain stores ──────────────────────────────────────────────────────────────

var economy: EconomyStore
var inventory: InventoryStore


func _ready() -> void:
	economy = EconomyStore.new()
	inventory = InventoryStore.new()
	SaveManager.register_provider(self)

# ══ Save contract (fan-out across Stores) ═════════════════════════════════════


## Merges every Store's payload into one sections dict, keyed by section_id().
func to_dict() -> Dictionary:
	var out: Dictionary = {}
	out[economy.section_id()] = economy.to_dict()
	out[inventory.section_id()] = inventory.to_dict()
	return out


## Restores every Store from the full sections dict; each reads its own key.
func from_dict(data: Dictionary) -> void:
	economy.from_dict(data.get(economy.section_id(), {}))
	inventory.from_dict(data.get(inventory.section_id(), {}))


## Aggregates validate() across all Stores. Returns true only when all pass.
func validate() -> bool:
	var ok := true
	ok = economy.validate() and ok
	ok = inventory.validate() and ok
	return ok

# ══ Transactions (the only mutation entry points) ═════════════════════════════


## Cross-domain transaction: buy [param entity] — spend its value from cash and
## add it to the inventory, saving exactly once on success. Aborts (returns false,
## no mutation, no save) if the entity is already owned or cash is insufficient.
##
## This is the pattern the Store/Manager split exists for: the spend() result is a
## transactional dependency — if it fails, the whole purchase must roll back — so
## it is a direct call whose return value gates the rest, not a fire-and-forget
## event. The single SaveManager.save() at the end is the commit point.
func buy_entity(entity: ExampleEntityData) -> bool:
	if entity == null:
		return false
	if inventory.has_collected(entity.entity_id):
		return false
	if not economy.spend(entity.value):
		return false
	inventory.collect(entity.entity_id)
	EventBus.emit_signal("example_entity_collected", entity.entity_id)
	SaveManager.save()
	return true


## Grants [param amount] cash and saves. Single-domain transaction.
func grant_cash(amount: int) -> void:
	economy.earn(amount)
	SaveManager.save()


## Resets all owned state to a new-game baseline and saves.
func reset_all() -> void:
	economy.apply_delta(-economy.cash)
	inventory.clear()
	SaveManager.save()
