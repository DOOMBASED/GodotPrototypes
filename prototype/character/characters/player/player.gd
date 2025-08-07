# player.gd
class_name Player extends Character

@onready var input_manager: Node = $InputManager
@onready var movement_manager: Node = $MovementManager

func _ready() -> void:
	Global.set_player(self)

func _physics_process(_delta: float) -> void:
	if input_manager.direction:
		_movement_check()

func _movement_check() -> void:
	if input_manager.run:
		movement_manager.speed = movement_manager.run_speed
	else:
		movement_manager.speed = movement_manager.walk_speed
	movement_manager.move(input_manager.direction)
