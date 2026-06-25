# Tutorial Standard

This document defines the skeleton architecture for tutorial scripts, tutorial flow, tutorial anchors, and gameplay tutorial events in the sim-management preset.

Applies to:

- Tutorial infrastructure under `global/autoloads/director/`
- Tutorial script catalog entries in `TutorialScripts`
- Scene tutorial anchor registration via `Director.register_scene()` / `register_anchor()` / `unregister_anchor()`
- Gameplay tutorial milestone events emitted through `EventBus.tutorial_event`

Does not apply to:

- Non-tutorial UI hints, inline status labels, or scene-local feedback
- Global notifications, which belong to `ToastManager`
- Story scripting, branching narrative, or quest logic

## Ownership Boundary

Tutorial infrastructure has three layers: presentation, flow, and gameplay overrides.

`Director` is the presentation layer. It owns the anchor registry, offer prompt API, Help button API, and the presentation hook `render_step()`. Template skeletons leave overlay node creation empty; projects fill that in.

`ScriptDirector` is the flow layer. It owns the active tutorial id, active step list, current step index, wait-condition evaluation, runtime reset, and tutorial-seen marking.

`GameplayOverride` is a runtime-only autoload that stores named gameplay overrides. The flow layer pushes overrides; gameplay scenes read the override store and react to its `override_changed` signal. The override store is cleared on save-slot reset.

Rules:

- Do not add step-order state to `Director`.
- Do not make gameplay scenes call `ScriptDirector` to advance tutorial steps.
- Do not make gameplay scenes call `Director` for gameplay-affecting overrides.
- If a gameplay action should advance a tutorial step, emit `EventBus.tutorial_event`.

## Step Advance Kinds

Every `TutorialStep` has one advance kind.

| Kind | Owner | Completes when |
| --- | --- | --- |
| `NEXT` | Player UI | The player clicks the step's Next control. |
| `SCENE_ENTERED` | Scene registration | A matching scene calls `Director.register_scene()`. |
| `EVENT` | Gameplay event | A matching semantic tutorial event is emitted. |

## Script Catalog

Tutorial content lives in `TutorialScripts`. The catalog is the single surface for tutorial ids, step arrays, anchor ids, and advance conditions.

Minimal new script checklist:

1. Add `<id>_script()` to `TutorialScripts`.
2. Add `<id>` to `resolve_script()`.
3. Add `<id>` to `known_script_ids()`.
4. Ensure every hint anchor id is registered by the relevant scene or transient popup.
5. Ensure every `EVENT` step has a corresponding `EventBus.tutorial_event.emit(...)` call.

## Scene Anchors

Scenes expose tutorial targets by registering anchors.

Persistent scene anchors use `Director.register_scene(scene_id, anchors)` in the scene root `_ready()` after the nodes exist.

Transient anchors use `Director.register_anchor(id, anchor)` when opened and `Director.unregister_anchor(id)` when closed. Use this for popups, option choosers, or any UI that does not exist for the scene's full lifetime.

Rules:

- Anchor ids are semantic UI ids, not node paths.
- Anchor ids must be stable enough for tutorial scripts to reference.
- Register plain `Control` nodes for simple rectangular targets.
- Use `TutorialTarget` when the highlight rect needs a custom region or preferred placement side.
- Do not leave transient anchors registered after the UI closes.

## Tutorial Events

Gameplay systems emit semantic tutorial milestones through `EventBus.tutorial_event`.

Rules:

- Event ids live in `TutorialEvents` as `StringName` constants.
- Emit tutorial events after the gameplay action has successfully committed.
- Do not include tutorial script ids or step ids in gameplay event payloads.
- Payload is reserved for future filtering.

## Persistence

Tutorial seen flags live in `ProgressStore`, owned by the relevant System. Runtime tutorial state is not persisted.

Persisted:

- `ProgressStore.tutorial_seen`
- `ProgressStore.onboarding_pending`

Runtime-only:

- Active script id
- Step index
- Registered anchors
- Gameplay overrides

`EventBus.save_runtime_reset` clears runtime-only tutorial state via `ScriptDirector.reset_runtime()` and `GameplayOverride.clear_all()`.
