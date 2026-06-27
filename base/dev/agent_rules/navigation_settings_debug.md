# Navigation, Settings, And Debug Rule

Read this before changing scene navigation, the Start Page, settings UI/storage, or debug-only behavior.

## Required References

- Scene navigation: read `dev/standards/scene_routing_standard.md` and use `dev/skills/scene_router_usage.md`.
- Start Page: read `dev/standards/start_page_standard.md`.
- Settings: read `dev/standards/settings_overlay_standard.md` and use `dev/skills/settings_overlay_usage.md`.
- Debug code: read `dev/standards/debug_standard.md` and use `dev/skills/debug_mode_usage.md`.

## Hard Rules

- Do not put scene routing back into `GameManager`.
- Do not bypass `SceneRouter` from normal gameplay screens.
- Do not store user/device preferences in gameplay saves.
- Do not add debug behavior outside `Debug.enabled`.
- Keep the base Start Page generic; save-slot and profile flows belong in a project or preset that owns them.
