# _global.gd
extends Node

@onready var global_ui: Control = $Interface/GlobalUI
var viewport: SubViewportContainer = null
var worldspace: Worldspace = null
var lighting_color: CanvasModulate = null
var player: Player = null

var hours_per_daytime: int = 12
var hours_per_nighttime: int = 12
var seconds_per_hour: float = 30.0
var starting_hour: int = 6
var daytime_color := Color(1.0, 1.0, 1.0)
var nightime_color := Color(0.1, 0.1, 0.3)
var time_in_hours: float = 0.0
var total_day_length: float = 0.0

signal player_set
signal worldspace_set

func _ready() -> void:
	total_day_length = hours_per_daytime + hours_per_nighttime
	time_in_hours = fmod(starting_hour, total_day_length)

func _process(delta: float) -> void:
	time_in_hours += delta / seconds_per_hour
	time_in_hours = fmod(time_in_hours, total_day_length)
	var blend_factor: float = 0.0
	if time_in_hours < hours_per_daytime:
		var t = time_in_hours / hours_per_daytime
		blend_factor = sin(t * PI)
	else:
		var t = (time_in_hours - hours_per_daytime) / hours_per_nighttime
		blend_factor = sin(t * PI)
	lighting_color.color = nightime_color.lerp(daytime_color, blend_factor)

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
	lighting_color = worldspace.lighting_color
	worldspace_set.emit()

func set_player(player_instance: Player) -> void:
	player = player_instance
	player_set.emit()

func set_debug_text(new_text: String) -> void:
	if global_ui.debug_label.text == "DEBUG: ":
		global_ui.debug_label.text = str("DEBUG: ", new_text)
		global_ui.debug_label.self_modulate = Color.RED
		await get_tree().create_timer(PI).timeout
		global_ui.debug_label.self_modulate = Color.WHITE
		global_ui.debug_label.text = "DEBUG: "

func get_current_hour() -> int:
	return int(time_in_hours)

func get_current_minute() -> int:
	return int((time_in_hours - int(time_in_hours)) * 60)

func is_daytime() -> bool:
	return time_in_hours < hours_per_daytime

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
