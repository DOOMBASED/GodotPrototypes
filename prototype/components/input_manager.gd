# player_input.gd
extends Node

var direction: Vector2
var run: bool

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		run = Input.is_action_pressed("run")
	else:
		run = false
