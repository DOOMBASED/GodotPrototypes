# _global.gd
extends Node

@onready var global_ui: Control = $Interface/GlobalUI
var viewport: SubViewportContainer = null
var worldspace: Worldspace = null
var player: Player = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("time_slow"):
			_set_time_slow()
		if Input.is_action_just_pressed("time_fast"):
			_set_time_fast()

func set_viewport(current_viewport: SubViewportContainer) -> void:
	viewport = current_viewport

func set_worldspace(current_worldspace: Worldspace) -> void:
	worldspace = current_worldspace

func set_player(player_instance: Player) -> void:
	player = player_instance

func set_debug_text(new_text: String) -> void:
	global_ui.debug_label.text = str("DEBUG: ", new_text)
	global_ui.debug_label.self_modulate = Color.RED
	await get_tree().create_timer(PI).timeout
	global_ui.debug_label.self_modulate = Color.WHITE
	global_ui.debug_label.text = "DEBUG: "

func _set_time_slow() -> void:
	if Engine.time_scale == 1.0:
		Engine.time_scale = 0.5
	elif Engine.time_scale == 0.5:
		Engine.time_scale = 1.0

func _set_time_fast() -> void:
	if Engine.time_scale == 1.0:
		Engine.time_scale = 10.0
	elif Engine.time_scale == 10.0:
		Engine.time_scale = 1.0
