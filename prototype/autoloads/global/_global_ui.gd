# _global_ui.gd
extends Control

@onready var global: PanelContainer = $Global
@onready var fps_label: Label = $Global/MarginContainer/HBoxContainer/FPSLabel
@onready var time_label: Label = $Global/MarginContainer/HBoxContainer/TimeLabel
@onready var debug_label: Label = $Global/MarginContainer/HBoxContainer/DebugLabel
@onready var death_message: Label = $DeathMessage

func _process(_delta: float) -> void:
	fps_label.text = str("FPS: ", str(Engine.get_frames_per_second()).pad_zeros(2), " |")
	time_label.text = str(str("TIME: ", Global.get_current_hour()).pad_zeros(2), ":" , str(Global.get_current_minute()).pad_zeros(2), " |")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_debug"):
			global.visible = not global.visible
