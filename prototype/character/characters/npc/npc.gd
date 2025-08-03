# npc.gd
class_name NPC extends Character

var player_in_range: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact"):
			if player_in_range:
				_dialogue_start()

func _dialogue_start() -> void:
	Global.set_debug_text(str(resource.name, ": Dialogue"))

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
