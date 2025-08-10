# _dialogue.gd
extends Node

@onready var dialogue_ui: Control = $Interface/DialogueUI
@onready var dialogues: Dictionary = {}

func dialogue_load(file_path: String) -> void:
	var data: String = FileAccess.get_file_as_string(file_path)
	var parsed_data: Dictionary = JSON.parse_string(data)
	if parsed_data:
		dialogues = parsed_data
	else:
		Global.set_debug_text(str("Failed to parse: ", str(parsed_data)))

func dialogue_retrieve(npc_id: String) -> Array:
	if npc_id in dialogues:
		return dialogues[npc_id]["trees"]
	else:
		return []
