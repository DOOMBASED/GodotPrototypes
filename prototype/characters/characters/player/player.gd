# player.gd
class_name Player extends Character

@onready var animation_manager: AnimationManager = $AnimationManager
@onready var input_manager: InputManager = $InputManager
@onready var movement_manager: MovementManager = $MovementManager
@onready var stats_manager: StatsManager = $StatsManager
@onready var weapon_manager: WeaponManager = $WeaponManager

func _ready() -> void:
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
		Stats.stats["stamina_exp"] += Stats.base_exp_rate
		movement_manager.speed = movement_manager.run_speed
		input_manager.direction = input_manager.direction.normalized().round()
		if stats_manager.stamina <= 0.0:
			stats_manager.stamina = 0.0
			stats_manager.stamina_cooldown = true
	else:
		movement_manager.speed = movement_manager.walk_speed
	movement_manager.move(delta, input_manager.direction)
