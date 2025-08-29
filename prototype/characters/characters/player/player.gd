# player.gd
class_name Player extends Character

@onready var shadow: Sprite2D = $Shadow
@onready var collision: CollisionShape2D = $Collision
@onready var animation_manager: AnimationManager = $AnimationManager
@onready var input_manager: InputManager = $InputManager
@onready var movement_manager: MovementManager = $MovementManager
@onready var stats_manager: StatsManager = $StatsManager
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var light: PointLight2D = $Light

func _ready() -> void:
	Global.time_is_dawn.connect(_at_dawn_hour)
	Global.time_is_dusk.connect(_at_dusk_hour)
	SignalBus.dead.connect(_on_death)
	Global.set_player(self)
	name = resource.name

func _physics_process(delta: float) -> void:
	if input_manager.direction:
		_movement_check(delta)
	else:
		movement_manager.moving = false
		movement_manager.velocity = Vector2.ZERO

func _movement_check(delta: float) -> void:
	if movement_manager.moving and input_manager.run  and stats_manager.stamina > 0.0 and not stats_manager.stamina_cooldown:
		stats_manager.stamina -= stats_manager.stamina_drain
		Stats.exp_stats["stamina_exp"] += Stats.base_exp_rate / PI
		movement_manager.speed = movement_manager.run_speed
		input_manager.direction = input_manager.direction.normalized().round()
		if stats_manager.stamina <= 0.0:
			stats_manager.stamina = 0.0
			stats_manager.stamina_cooldown = true
	else:
		movement_manager.speed = movement_manager.walk_speed
	movement_manager.char_move(delta, input_manager.direction)

func _at_dawn_hour() -> void:
	shadow.visible = true
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.WHITE, 60.0)
	await shadow_tween.finished

func _at_dusk_hour() -> void:
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.TRANSPARENT, 60.0)
	await shadow_tween.finished
	shadow.visible = false

func _on_death(character: Character) -> void:
	if character == self:
		z_index = -1
		collision.disabled = true
