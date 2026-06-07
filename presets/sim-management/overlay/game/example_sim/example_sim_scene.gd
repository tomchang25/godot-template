# example_sim_scene.gd
# Block 01 (sim-management) — reference scene for the Store/Manager model.
# Lists example entities; each can be BOUGHT for its value, which spends cash
# (EconomyStore) and adds it to inventory (InventoryStore) via a single
# GameStateManager transaction. Demonstrates: Manager-gated mutation, Store reads,
# SaveManager save/load, EventBus signal.
# Reads:  GameStateManager.economy.cash, GameStateManager.inventory.collected_ids
# Writes: (none directly — all writes go through GameStateManager transactions)
extends Control

# ── Node references ───────────────────────────────────────────────────────────

@onready var _cash_label: Label = $RootVBox/CashLabel
@onready var _entity_list: ItemList = $RootVBox/EntityList
@onready var _save_button: Button = $RootVBox/ButtonRow/SaveButton
@onready var _load_button: Button = $RootVBox/ButtonRow/LoadButton
@onready var _reset_button: Button = $RootVBox/ButtonRow/ResetButton


# ══ Lifecycle ═════════════════════════════════════════════════════════════════

func _ready() -> void:
	_entity_list.item_selected.connect(_on_entity_selected)
	_save_button.pressed.connect(_on_save_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_refresh()


# ══ Signal handlers ════════════════════════════════════════════════════════════

func _on_entity_selected(index: int) -> void:
	var entity_id: String = _entity_list.get_item_metadata(index)
	var entity: ExampleEntityData = ExampleRegistry.get_example_by_id(entity_id)
	# Mutation goes through the Manager — the scene never touches a Store directly.
	GameStateManager.buy_entity(entity)
	_refresh()


func _on_save_pressed() -> void:
	SaveManager.save()


func _on_load_pressed() -> void:
	SaveManager.load()
	_refresh()


func _on_reset_pressed() -> void:
	GameStateManager.reset_all()
	_refresh()


# ══ View ══════════════════════════════════════════════════════════════════════

func _refresh() -> void:
	_cash_label.text = "Cash: %d" % GameStateManager.economy.cash
	var owned: Array[String] = GameStateManager.inventory.collected_ids
	_entity_list.clear()
	for entity: ExampleEntityData in ExampleRegistry.get_all_examples():
		var is_owned: bool = owned.has(entity.entity_id)
		var label: String = "%s  (buy: %d)%s" % [
			entity.display_name,
			entity.value,
			"  ✓ owned" if is_owned else "",
		]
		_entity_list.add_item(label)
		_entity_list.set_item_metadata(_entity_list.item_count - 1, entity.entity_id)
