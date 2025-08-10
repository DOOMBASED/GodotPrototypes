# input_manager.gd
extends Node

@onready var player: Player = get_parent()
var direction: Vector2
var run: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_pressed("action"):
			if player.animation_manager.equip_anim != "":
				player.animation_manager.action_start()
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		run = Input.is_action_pressed("run")
	else:
		run = false
