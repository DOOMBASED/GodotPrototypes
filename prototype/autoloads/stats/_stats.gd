# _stats.gd
extends Node

var exp_stats: Dictionary = {}
var kill_stats: Dictionary = {}

var base_exp_rate: float = 0.01

signal exp_updated
signal kills_updated

func _ready() -> void:
	await Global.player_set
	_init_stats_exp()
	_init_stats_kills()

func _init_stats_exp() -> void:
	exp_stats["Health"] = 0.0
	exp_stats["Stamina"] = 0.0
	exp_stats["Magic"] = 0.0
	exp_stats["Melee"] = 0.0
	exp_stats["Ranged"] = 0.0
	exp_stats["Farming"] = 0.0
	exp_stats["Woodcutting"] = 0.0
	exp_stats["Mining"] = 0.0
	exp_updated.emit()

func _init_stats_kills() -> void:
	kills_updated.emit()
