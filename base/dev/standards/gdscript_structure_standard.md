# GDScript Structure Standard

This document defines shared GDScript file structure rules. It applies to scene scripts, reusable UI components, autoloads, data resources, stores, systems, services, managers, and tests unless a narrower standard overrides one section.

Applies especially to:

- Block scene root scripts
- Testbed scenes
- Reusable UI component scripts
- Common framework scripts
- Autoloads and managers
- Resource definitions under `data/`

---

# 1. File Header

Every script must begin with a file header comment block.

Format:

```gdscript
# script_name.gd
# One-line description of this script's responsibility.
```

Scene scripts may add state annotations when useful:

```gdscript
# script_name.gd
# One-line description of this scene's responsibility.
# Reads:  SomeManager.state.field_name
# Writes: SomeManager.state.field_name
```

Rules:

- The first line is the filename.
- The second line is a single-sentence responsibility summary.
- `Reads` and `Writes` list managed state fields this script touches when that makes scene flow easier to review.
- If the script reads nothing, omit the `Reads` line.
- If the script writes nothing, omit the `Writes` line.

Testbed variant:

```gdscript
# script_name.gd
# Testbed for [Feature]; bypasses [normal dependency].
#
# Run this scene to test [Feature] in isolation.
# Edit the @export fields in the Inspector to configure fake state.
```

---

# 2. Declaration Order

Declarations at the top of the file follow this order:

```gdscript
@tool (if needed)
class_name (if needed)
extends

inner classes (if any)

signals
enums

const
preload constants

@export / @export_group

private variables

@onready
```

Rules:

- `@tool` goes on the very first line when present, before `class_name` and `extends`.
- `class_name` goes before `extends`, matching Godot's generated script order.
- Inner classes go immediately after `class_name` / `extends`, before constants, variables, and function sections.
- Signals are declared before constants so they appear first in the class contract.
- Enums follow signals, as they can be used as export type hints and const initializers.
- Constants and preloads come before `@export` so export default values can reference them.
- `@onready` goes last because it is resolved after `_ready()` enters the scene tree.
- `class_name` is only added when the script needs to be referenced by type elsewhere. Omit it for scene root scripts that are never typed directly.

---

# 3. Variable Block Headers

Variable groups at the top of the file use the single-line (`--`) format.

```gdscript
# -- Group name --
```

Use a consistent label from the table below.

Standard variable groups, in order:

| Header | Contents |
| --- | --- |
| `# -- Constants --` | `const` and `preload` |
| `# -- Exports --` | `@export` vars |
| `# -- State --` | Runtime logic variables |
| `# -- Timer / tween handles --` | `Timer`, `Tween` vars |
| `# -- Node references --` | `@onready` node references bound to `.tscn` nodes via `%UniqueName` |

Rules:

- Only include groups that have at least one variable.
- Do not create custom group names unless no standard label fits.

---

# 4. Function Section Headers

Function groups use the double-line (`==`) format.

```gdscript
# == Section name ==
```

Use ASCII `=` and `-` header characters. Do not pad headers to a fixed column.

---

# 5. Section Order

The same main section order applies across script types. Types differ in their subsection names, not in the top-level ordering rules.

Sections appear in this fixed order:

```gdscript
Inner classes
Lifecycle
Overridden custom methods
Signal handlers
Common API
Feature section 1
Feature section 2
...
```

## Inner Classes

Placed immediately after `class_name` / `extends` and before constants, variables, and function sections.

```gdscript
# == Inner classes ==

class _ClassName extends BaseClass:
    ...
```

## Lifecycle

Contains only Godot built-in virtual callbacks, in this order when present:

```gdscript
_init()
_enter_tree()
_ready()
_process()
_physics_process()
remaining virtual methods
```

No private helpers here. Helpers belong in their feature section.

```gdscript
# == Lifecycle ==

func _ready() -> void:
    ...

func _unhandled_input(event: InputEvent) -> void:
    ...
```

## Overridden Custom Methods

Methods overriding a non-Godot base class contract go after Godot lifecycle and before signal handlers. Omit this section when the script has no custom overrides.

## Signal Handlers

Contains only `_on_xxx()` callbacks. No public functions. No logic helpers.

```gdscript
# == Signal handlers ==

func _on_confirm_pressed() -> void:
    ...

func _on_cancel_pressed() -> void:
    ...
```

## Common API

All public methods that other scripts may call go here, including public static methods such as `from_dict()` and paired instance methods such as `to_dict()`. Do not split public static methods into a separate main section.

```gdscript
# == Common API ==

static func from_dict(data: Dictionary) -> EntryType:
    ...

func to_dict() -> Dictionary:
    ...

func setup(entry: EntryType) -> void:
    ...
```

## Feature Sections

Domain-specific private implementation groups. Feature sections contain private helpers only; move public methods to `Common API` even when they belong to a specific domain concept.

```gdscript
# == Rows ==

func _populate_rows() -> void:
    ...

# == Result ==

func _commit_result() -> void:
    ...
```

Use descriptive domain names that reflect the feature, not the project's current block list. Subsections inside `Common API` or a feature section use single-line headers and may differ by script type.

Runtime UI construction is a scene-only exception. When it is genuinely required by the scene node source standard, keep `_build_ui()` and its private builder helpers together as one feature section. Most scenes should not have this section at all.

---

# 6. Inline Sub-section Comments

Long functions may use inline sub-section comments to mark regions.

Format:

```gdscript
    # -- Sub-section label --
```

Only add inline sub-sections when the function is long enough to need navigation. Short functions under roughly 15 lines do not need them.

---

# 7. Private vs Public Placement Rule

Private functions belong inside the section they serve, not in a global private section at the bottom.

```gdscript
# == Result ==

func _commit_result() -> void:
    ...

func _show_summary() -> void:
    ...
```

Exception: `_on_xxx` signal callbacks always go in `# == Signal handlers ==`, regardless of which feature they relate to.

---

# 8. Complete Layout Reference

```gdscript
# script_name.gd
# One-line description.
extends Control

# -- Constants --

const MAX_SLOTS := 6
const ItemRowScene := preload("uid://...")

# -- State --

var _items: Array[ExampleEntry] = []

# -- Node references --

@onready var _row_container: VBoxContainer = %RowContainer
@onready var _continue_button: Button = %ContinueButton


# == Lifecycle ==

func _ready() -> void:
    _continue_button.pressed.connect(_on_continue_pressed)
    _populate_rows()


# == Signal handlers ==

func _on_continue_pressed() -> void:
    SceneRouter.go_to(&"next_scene")


# == Rows ==

func _populate_rows() -> void:
    for entry: ExampleEntry in _items:
        var row: ExampleRow = ItemRowScene.instantiate()
        row.setup(entry)
        row.row_pressed.connect(_on_row_pressed)
        _row_container.add_child(row)
```

---

# 9. Header Reference

Headers use short ASCII markers and are not padded to a fixed column.

```gdscript
# -- Label --
# == Label ==
    # -- Label --
```

Legacy padded or Unicode headers may remain in old files. When editing a file that uses the old format, update touched headers to the short ASCII format opportunistically rather than performing bulk-only rewrites.

---

# 10. Node Source Rule

Node-source rules are defined in `dev/standards/scene_node_source_standard.md`.

For this standard's scope, all persistent nodes in scenes, testbeds, and reusable UI components must be defined in `.tscn` and referenced from GDScript with `@onready`. Runtime-created nodes are allowed only for the permitted cases documented in the scene node source standard.

---

# 11. Signal Connections

Connect signals between a scene's own nodes in `_ready()`, not in the `.tscn`. This keeps the full connection surface visible in code without IDE dependency for wiring.

Connections go at the top of `_ready()`, before any logic or node setup:

```gdscript
func _ready() -> void:
    _confirm_button.pressed.connect(_on_confirm_pressed)
    _cancel_button.pressed.connect(_on_cancel_pressed)
    # ... rest of setup
```

This applies to all signal connections: buttons, custom signals from child nodes, and connections to autoloads.

---

# 12. Instantiating Packed Scenes

When instantiating a reusable component scene into a container, follow this fixed order:

```gdscript
for entry: ExampleEntry in _items:
    var row: ExampleRow = ExampleRowScene.instantiate()  # 1. instantiate
    row.setup(entry)                                     # 2. apply data
    row.row_pressed.connect(_on_row_pressed)             # 3. connect signals
    _row_container.add_child(row)                        # 4. add to tree
```

Why this order:

- `setup()` before `add_child()` because `add_child()` triggers the child's `_ready()`. Applying data first means `_ready()` runs with the node already populated.
- `connect()` before `add_child()` ensures every listener is attached before any signal the child might emit during `_ready()`.

The component's `setup()` is its apply function: a single public entry point that takes all data the component needs and leaves the component ready to display. Components should not rely on setters, direct property assignment, or post-construction tweaking from the parent. If the component must also support updates after being shown, expose a separate `refresh()` with no arguments.

---

# 13. Component `setup()` Implementation

A reusable component's `setup()` is its apply function, but it has a specific internal shape because it may be called either before or after the component enters the scene tree.

```gdscript
# -- State --

var _entity: ExampleEntityData = null

# -- Node references --

@onready var _name_label: Label = %NameLabel


# == Lifecycle ==

func _ready() -> void:
    _select_button.pressed.connect(func() -> void: selected.emit())

    if _entity != null:
        _apply()


# == Common API ==

func setup(entity: ExampleEntityData) -> void:
    _entity = entity

    if is_node_ready():
        _apply()


func refresh() -> void:
    if is_node_ready():
        _apply()


# == View ==

func _apply() -> void:
    _name_label.text = _entity.display_name
```

Rules:

- `setup()` only stores arguments to private variables, then calls `_apply()` guarded by `is_node_ready()`. It must not touch any `@onready` node directly.
- `_apply()` is private, takes no arguments, reads private state, and writes the `@onready` nodes. It is the only function that touches view nodes.
- `_ready()` connects signals first, then calls `_apply()` if private state has already been populated by an earlier `setup()` call.
- `refresh()`, if exposed, calls `_apply()` guarded by `is_node_ready()`. It never re-assigns private state.

Do not write components that paint directly inside `setup()` without the guard. They work only when the parent happens to call `setup()` after `add_child()` and break when someone flips the order.

---

# 14. Component `.tscn` Default Content

A component's `.tscn` defines the full node tree with neutral placeholder values in every user-visible field: not blank strings, not real data, not leftover editor text.

Use values that clearly read as not yet populated:

```text
text = " - "
text = "? / ?"
text = "0"
```

Reason: between the moment the component enters the tree and the moment `_apply()` runs, its nodes are visible. Placeholders make the intermediate frame read as an unpopulated shell and make missed `_apply()` writes obvious during development.
