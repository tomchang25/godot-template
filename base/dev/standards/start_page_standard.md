# Start Page Standard

The Start Page is the shared project entry point for the base and all preset overlays.

---

# 1. Role

The Start Page is a neutral title screen. It starts the default route, opens Settings, and quits. It must not contain project-specific save-slot logic, campaign flow, account login, or mode selection unless a concrete project owns those requirements.

The base Start Page lives at `game/meta/start/start_page_scene.tscn` and is the `run/main_scene` in `project.godot`.

---

# 2. Required Actions

- Start calls `SceneRouter.go_to_default()`.
- Settings calls `SettingsStore.toggle_overlay()`.
- Quit calls `get_tree().quit()`.

Preset projects choose where Start goes by changing `SceneRegistry.default_route` in their `scene_router.tscn` overlay. Do not set a preset's `run/main_scene` directly to its gameplay scene.

---

# 3. Extension Rule

Add project-specific menu features only in the project or preset that owns them. Examples: save slots, profile picker, chapter select, demo mode, or platform account sign-in. Keep the base Start Page generic.

When adding persistent UI nodes to the Start Page, define them in `.tscn` and reference them with `%UniqueName` from the script. Runtime-created debug-only controls must be gated by `Debug.enabled` and marked with `# node-src: debug`.
