# store_base.gd
# Base class for all Store archetypes. A Store is the Model layer of the
# sim-management preset: a serialisable, mutation-guarded slice of one domain's
# state, held by a Manager. StoreBase provides no-op defaults for the save
# interface so subclasses override only what they need.
#
# Persisting Stores override section_id / to_dict / from_dict / validate.
# Session-scoped Stores (cleared each run, never saved) override none — they
# carry no save payload and are never handed to SaveManager.
class_name StoreBase
extends RefCounted


## Section key for this store's payload in the save file. "" by default, which
## session-scoped Stores (never registered for save) rely on.
func section_id() -> String:
	return ""


## Serializes this store's state to a Dictionary. Empty by default. Convention:
## include "_version": _store_version() so from_dict can migrate older payloads.
func to_dict() -> Dictionary:
	return {}


## Restores this store's state from [param data]. No-op by default. Subclasses
## read _version, run _apply_migrations, then read fields.
func from_dict(_data: Dictionary) -> void:
	pass


## Validates invariants / referential integrity of restored state. true by default.
## Drop unresolved ids with push_warning here — never fault a load.
func validate() -> bool:
	return true


## Current schema version for this store. Override when adding an _apply_migrations
## branch so old saves are detected and upgraded.
func _store_version() -> int:
	return 1


## Transforms saved [param data] from [param from_version] to the current version.
## Migrations chain sequentially, each block stepping one version forward:
##
##   func _apply_migrations(data: Dictionary, from_version: int) -> Dictionary:
##       if from_version < 2:
##           data["new_field"] = data.get("old_field", 0)
##           data.erase("old_field")
##       return data
##
## The caller (from_dict) reads _version from the payload and passes it here.
func _apply_migrations(data: Dictionary, _from_version: int) -> Dictionary:
	return data
