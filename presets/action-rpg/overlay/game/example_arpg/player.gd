# player.gd
# Entity subclass — player. Local behaviour only: read input, move the body, and
# pulse the attack Hitbox. Health / Hurtbox / Hitbox capabilities live on the
# component children (see player.tscn). Nothing here mutates another entity's state.
extends Entity

# ── Constants ─────────────────────────────────────────────────────────────────

const SPEED := 220.0
const ATTACK_SECONDS := 0.15

# ── Node references ───────────────────────────────────────────────────────────

@onready var _attack_hitbox: Hitbox = $AttackHitbox

# ── State ─────────────────────────────────────────────────────────────────────

var _attack_timer: Timer


# ══ Lifecycle ═════════════════════════════════════════════════════════════════

func _ready() -> void:
	super()
	_attack_hitbox.set_enabled(false)
	# node-src: timer
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.timeout.connect(func() -> void: _attack_hitbox.set_enabled(false))
	add_child(_attack_timer)


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * SPEED
	move_and_slide()
	if Input.is_action_just_pressed("ui_accept"):
		_attack()


# ══ Attack ════════════════════════════════════════════════════════════════════

func _attack() -> void:
	_attack_hitbox.set_enabled(true)
	_attack_timer.start(ATTACK_SECONDS)
