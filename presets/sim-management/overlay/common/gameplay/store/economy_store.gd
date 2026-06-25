# economy_store.gd
# Economy domain Store: cash on hand. Reference Store showing the full shape —
# private backing field, read-only public getter, mutation-guarded operations,
# save payload, and per-store migration. Held by ExampleSystem.
#
# Fields are read-public via getters. There is no external setter, so the only
# write path is through the operations below (and thus through the Manager).
class_name EconomyStore
extends StoreBase

var _cash: int = 0

## Cash on hand. Read-only externally — no setter means no external write path.
var cash: int:
	get:
		return _cash

# ══ Operations (the only write path) ══════════════════════════════════════════


## Returns true if [param amount] can be spent without going negative.
func can_afford(amount: int) -> bool:
	return _cash >= amount


## Deducts [param amount]. Refuses (returns false) if cash would go negative.
## Guards non-negative input — a negative amount is a caller bug.
func spend(amount: int) -> bool:
	if amount < 0:
		ToastManager.show_dev_error("spend() expects a non-negative amount")
		return false
	if _cash < amount:
		return false
	_cash -= amount
	return true


## Adds [param amount] to cash. Guards non-negative input.
func earn(amount: int) -> void:
	if amount < 0:
		ToastManager.show_dev_error("earn() expects a non-negative amount")
		return
	_cash += amount


## Applies a signed [param delta] atomically; may drive cash negative (e.g. a
## daily upkeep cost). Use sparingly — prefer earn/spend.
func apply_delta(delta: int) -> void:
	_cash += delta

# ══ Save contract ═════════════════════════════════════════════════════════════


func section_id() -> String:
	return "economy"


func to_dict() -> Dictionary:
	return {"_version": _store_version(), "cash": _cash}


func from_dict(data: Dictionary) -> void:
	var version: int = int(data.get("_version", 1))
	data = _apply_migrations(data, version)
	_cash = int(data.get("cash", _cash))
