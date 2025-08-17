# _global_ui.gd
extends Control

@onready var global: PanelContainer = $Global
@onready var debug_label: Label = $Global/MarginContainer/DebugLabel

func _process(_delta: float) -> void:
	pass #fps_label.text = str(Engine.get_frames_per_second() as int)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_debug"):
			global.visible = not global.visible
