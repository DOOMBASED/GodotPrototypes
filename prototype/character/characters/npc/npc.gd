# npc.gd
class_name NPC extends Character

var player_in_range: bool = false

@onready var dialogue_manager: Node = $DialogueManager

func _ready() -> void:
	dialogue_manager.npc = self

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact"):
			if player_in_range:
				dialogue_manager.dialogue_start()

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if Dialogue.dialogue_ui.visible:
			Dialogue.dialogue_ui.dialogue_ui_hide()
