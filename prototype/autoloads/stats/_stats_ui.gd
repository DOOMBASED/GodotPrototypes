# _stats_ui.gd
extends Control

@onready var stats_display: PanelContainer = $StatsDisplay
@onready var exp_labels: VBoxContainer = $StatsDisplay/MarginContainer/VBoxContainer/ExpLabels
@onready var kill_labels: VBoxContainer = $StatsDisplay/MarginContainer/VBoxContainer/KillLabels
@onready var hunger_bar: TextureProgressBar = $StatsBars/MarginContainer/VBoxContainer/HBoxContainer/HungerBar
@onready var thirst_bar: TextureProgressBar = $StatsBars/MarginContainer/VBoxContainer/HBoxContainer/ThirstBar
@onready var health_bar: TextureProgressBar = $StatsBars/MarginContainer/VBoxContainer/HealthBar
@onready var stamina_bar: TextureProgressBar = $StatsBars/MarginContainer/VBoxContainer/StaminaBar
@onready var magic_bar: TextureProgressBar = $StatsBars/MarginContainer/VBoxContainer/MagicBar
var hunger_tween: Tween
var thirst_tween: Tween
var health_tween: Tween
var stamina_tween: Tween
var hunger_float: float
var thirst_float: float
var health_float: float
var stamina_float: float

func _ready() -> void:
	Stats.exp_updated.connect(_on_exp_updated)
	Stats.kills_updated.connect(_on_kills_updated)

func _process(_delta: float) -> void:
	check_stats_bars()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_stats"):
			stats_display.visible = not stats_display.visible

func check_stats_bars() -> void:
	if Global.player:
		if Global.player.stats_manager.hunger == Global.player.stats_manager.hunger_max:
				hunger_bar.value = hunger_bar.max_value
		if Global.player.stats_manager.thirst == Global.player.stats_manager.thirst_max:
				thirst_bar.value = thirst_bar.max_value
		if Global.player.stats_manager.health == Global.player.stats_manager.health_max:
				health_bar.value = health_bar.max_value
		if Global.player.stats_manager.stamina == Global.player.stats_manager.stamina_max:
				stamina_bar.value = stamina_bar.max_value
		if hunger_bar.value < Global.player.stats_manager.hunger or Global.player.stats_manager.hunger < Global.player.stats_manager.hunger_max:
			hunger_float = Global.player.stats_manager.hunger
			hunger_tween = create_tween()
			hunger_tween.tween_property(hunger_bar, "value", hunger_float, 0.1)
		if thirst_bar.value < Global.player.stats_manager.thirst or Global.player.stats_manager.thirst < Global.player.stats_manager.thirst_max:
			thirst_float = Global.player.stats_manager.thirst
			thirst_tween = create_tween()
			thirst_tween.tween_property(thirst_bar, "value", thirst_float, 0.1)
		if health_bar.value < Global.player.stats_manager.health or Global.player.stats_manager.health < Global.player.stats_manager.health_max:
			health_float = Global.player.stats_manager.health
			health_tween = create_tween()
			health_tween.tween_property(health_bar, "value", health_float, 0.1)
		if stamina_bar.value < Global.player.stats_manager.stamina or Global.player.stats_manager.stamina < Global.player.stats_manager.stamina_max:
			stamina_float = Global.player.stats_manager.stamina
			stamina_tween = create_tween()
			stamina_tween.tween_property(stamina_bar, "value", stamina_float, 0.1)

func _on_exp_updated() -> void:
	for child: Label in exp_labels.get_children():
		exp_labels.remove_child(child)
		child.queue_free()
	for i: String in Stats.exp_stats:
		var exp_label: Label = Label.new()
		exp_label.text = str(i, " - ", str(Stats.exp_stats[i]).pad_decimals(2))
		exp_labels.add_child(exp_label)

func _on_kills_updated() -> void:
	for child: Label in kill_labels.get_children():
		kill_labels.remove_child(child)
		child.queue_free()
	for i: String in Stats.kill_stats:
		var kill_label: Label = Label.new()
		kill_label.text = str(i, " - ", str(Stats.kill_stats[i]))
		kill_labels.add_child(kill_label)
