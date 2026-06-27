# start_page_scene.gd
# Generic title screen with Start, Settings, and Quit actions.
extends Control

# -- Node references ----------------------------------------------------------

@onready var _start_btn: Button = %StartButton
@onready var _settings_btn: Button = %SettingsButton
@onready var _quit_btn: Button = %QuitButton


# == Lifecycle ================================================================


func _ready() -> void:
	_start_btn.pressed.connect(_on_start_pressed)
	_settings_btn.pressed.connect(_on_settings_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)


# == Signal handlers ===========================================================


func _on_start_pressed() -> void:
	SceneRouter.go_to_default()


func _on_settings_pressed() -> void:
	SettingsStore.toggle_overlay()


func _on_quit_pressed() -> void:
	get_tree().quit()
