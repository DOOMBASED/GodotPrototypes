# _global.gd
extends Node

@onready var global_ui: Control = $Interface/GlobalUI
var viewport: SubViewportContainer = null
var worldspace: Worldspace = null
var lighting_color: CanvasModulate = null
var player: Player = null
var daytime_color := Color(1.0, 1.0, 0.8)
var nightime_color := Color(0.1, 0.1, 0.2)
var days_passed: int = 0
var hours_per_daytime: int = 14
var hours_per_nighttime: int = 10
var seconds_per_hour: float = 10.0
var time_in_hours: float = 0.0
var total_day_length: float = 0.0

var daytime: bool
var nighttime: bool

const starting_hour: int = 4
const dawn_hour: int = 6
const dusk_hour: int = 18

signal player_set
signal worldspace_set
signal time_is_dawn
signal time_is_dusk

func _ready() -> void:
	total_day_length = hours_per_daytime + hours_per_nighttime
	time_in_hours = fmod(starting_hour, total_day_length)
	if time_in_hours > dawn_hour and time_in_hours < dusk_hour:
		daytime = true
		nighttime = false
	else:
		daytime = false
		nighttime = true

func _process(delta: float) -> void:
	time_in_hours += delta / seconds_per_hour
	time_in_hours = fmod(time_in_hours, total_day_length)
	if int(time_in_hours) == dawn_hour and nighttime:
		time_is_dawn.emit()
		daytime = true
		nighttime = false
		days_passed += 1
	if int(time_in_hours) == dusk_hour and daytime:
		time_is_dusk.emit()
		daytime = false
		nighttime = true
	var blend_factor: float = 0.0
	if time_in_hours < hours_per_daytime:
		blend_factor = lerp(0.0, 1.0, time_in_hours / hours_per_daytime)
	else:
		blend_factor = lerp(1.0, 0.0, (time_in_hours - hours_per_daytime) / hours_per_nighttime)
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
