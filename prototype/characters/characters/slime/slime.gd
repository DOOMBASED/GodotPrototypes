# slime.gd
class_name Slime extends Character

@onready var collision: CollisionShape2D = $Collision
@onready var movement_manager: MovementManager = $MovementManager
@onready var stats_manager: StatsManager = $StatsManager
@onready var navigation_manager: NavigationManager = $NavigationManager
@onready var animation_manager: AnimationManager = $AnimationManager
@onready var interact_area: Area2D = $InteractArea
@onready var test_health_label: Label = $Control/TestHealthLabel

var player_in_range: bool = false

func _ready() -> void:
	SignalBus.dead.connect(_on_death)
	name = resource.name

func _process(_delta: float) -> void:
	if navigation_manager.current_state == NavigationManager.NavigationState.SEARCH:
		test_health_label.text = str(stats_manager.health).pad_zeros(2).pad_decimals(0)
	if animation_manager.current_state == AnimationManager.AnimationState.DEAD:
		test_health_label.text = "DEAD"

func _physics_process(delta: float) -> void:
	if not navigation_manager.is_navigation_finished():
		_movement_check(delta)
	else:
		movement_manager.moving = false
		movement_manager.velocity = Vector2.ZERO

func _movement_check(delta: float) -> void:
	movement_manager.speed = movement_manager.walk_speed
	if navigation_manager.avoidance_enabled:
		movement_manager.char_move(delta, velocity)
	else:
		movement_manager.char_move(delta, navigation_manager.direction)

func _on_enemy_interact_area_body_entered(body: Node2D) -> void:
	if self is Slime:
		if body.is_in_group("Player"):
			player_in_range = true
			if body is Character:
				var direction = global_position.direction_to(body.global_position)
				body.movement_manager.knockback_direction = direction * resource.touch_knockback_force
				body.movement_manager.knockback = true
				body.stats_manager.health_damage(resource.touch_damage)

func _on_death(character: Character) -> void:
	if character == self:
		z_index = -1
		collision.disabled = true
		interact_area.monitoring = false
