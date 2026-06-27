# Block-Scene Data Flow (`setup()` / `_apply()`)

The data-injection half of the block-scene convention, specific to the UI-heavy
sim-management paradigm. The **node-source rule** (persistent nodes live in `.tscn`,
not `add_child()`; no `[connection]` in `.tscn`) is the neutral, lint-enforced half
and stays in the base: `dev/standards/scene_node_source_standard.md`. This
document adds the rule for *how data flows into a reusable component*.

## `setup()` is the apply function

A reusable component (row, card, panel) takes all the data it needs through a single
public `setup()` entry point and leaves itself ready to display. No setters, no
post-construction property tweaking from the parent — everything flows through
`setup()`. If the component must update after being shown, expose a separate
`refresh()` (no args, re-reads current state).

## The `setup()` / `_apply()` shape

`setup()` may be called either before or after the component enters the tree, so it
never touches `@onready` nodes directly:

```gdscript
# -- State --
var _entity: ExampleEntityData = null

# -- Node references --
@onready var _name_label: Label = $NameLabel

# == Lifecycle ==
func _ready() -> void:
    _buy_button.pressed.connect(func() -> void: buy_pressed.emit())
    if _entity != null:        # setup() already ran before we entered the tree
        _apply()

# == Common API ==
func setup(entity: ExampleEntityData) -> void:
    _entity = entity           # only stores args
    if is_node_ready():
        _apply()

# == View ==
func _apply() -> void:         # the ONLY function that writes @onready nodes
    _name_label.text = _entity.display_name
```

Rules:

- `setup()` only assigns private state, then calls `_apply()` guarded by
  `is_node_ready()`. It must not touch any `@onready` node.
- `_apply()` is private, takes no args, reads private state, writes every `@onready`
  node. It is the single source of paint truth.
- `_ready()` connects signals first, then calls `_apply()` if private state was
  already populated by an earlier `setup()`.

## Instantiation order

When instancing a component into a container, fixed order — `setup()` and `connect()`
both before `add_child()` (because `add_child()` triggers the child's `_ready()`):

```gdscript
var row: EntityRow = EntityRowScene.instantiate()   # 1. instantiate
row.setup(entity)                                    # 2. apply data
row.row_pressed.connect(_on_row_pressed)             # 3. connect signals
_row_container.add_child(row)                        # 4. add to tree
```

## `.tscn` default content

A component's `.tscn` carries neutral **placeholder** values in every user-visible
field (`text = " - "`, `text = "? / ?"`, leave textures null) — never real-looking
data. Between entering the tree and `_apply()` running, the nodes are visible; a
placeholder reads as "not yet populated", whereas leftover real data reads as a bug.
