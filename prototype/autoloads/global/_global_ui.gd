# _global_ui.gd
extends Control

@onready var global: PanelContainer = $Global
@onready var debug_label: Label = $Global/MarginContainer/DebugLabel

func _ready() -> void:
	global.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_debug"):
			global.visible = not global.visible
