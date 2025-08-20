# _stats_ui.gd
extends Control

@onready var health_bar: TextureProgressBar = $Stats/MarginContainer/VBoxContainer/HealthBar
@onready var stamina_bar: TextureProgressBar = $Stats/MarginContainer/VBoxContainer/StaminaBar
@onready var magic_bar: TextureProgressBar = $Stats/MarginContainer/VBoxContainer/MagicBar

var health_tween: float
var stamina_tween: float
var h_tween: Tween
var s_tween: Tween

func _process(_delta: float) -> void:
	check_stats_bars()

func check_stats_bars() -> void:
	if Global.player:
		if Global.player.stats_manager.health == Global.player.stats_manager.health_max:
				health_bar.value = health_bar.max_value
		if Global.player.stats_manager.stamina == Global.player.stats_manager.stamina_max:
				stamina_bar.value = stamina_bar.max_value
		if health_bar.value < Global.player.stats_manager.health or Global.player.stats_manager.health < Global.player.stats_manager.health_max:
			health_tween = Global.player.stats_manager.health
			h_tween = create_tween()
			h_tween.tween_property(health_bar, "value", health_tween, 0.1)
		if stamina_bar.value < Global.player.stats_manager.stamina or Global.player.stats_manager.stamina < Global.player.stats_manager.stamina_max:
			stamina_tween = Global.player.stats_manager.stamina
			s_tween = create_tween()
			s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)
