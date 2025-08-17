# npc.gd
class_name NPC extends Character

@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var movement_manager: MovementManager = $MovementManager
@onready var animation_manager: AnimationManager = $AnimationManager
@onready var navigation_manager: NavigationManager = $NavigationManager
@onready var weapon_collision: CollisionShape2D = $WeaponManager/Weapon/WeaponCollision

var player_in_range: bool = false

func _ready() -> void:
	dialogue_manager.npc = self
	weapon_collision.disabled = true
	name = resource.name

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact"):
			if player_in_range and not Dialogue.dialogue_ui.dialogue.visible:
				dialogue_manager.dialogue_start()

func _physics_process(delta: float) -> void:
	if not navigation_manager.is_navigation_finished():
		_movement_check(delta)
	else:
		movement_manager.moving = false
		movement_manager.velocity = Vector2.ZERO

func _movement_check(delta: float) -> void:
	movement_manager.speed = movement_manager.walk_speed
	if navigation_manager.avoidance_enabled:
		movement_manager.move(delta, velocity)
	else:
		movement_manager.move(delta, navigation_manager.direction)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
