# _stats.gd
extends Node

var stats: Dictionary = {}

var base_exp_rate: float = 0.01

func _ready() -> void:
	await Global.player_set
	_init_stats_exp()

func _init_stats_exp() -> void:
	stats["health_exp"] = 0.0
	stats["stamina_exp"] = 0.0
	stats["magic_exp"] = 0.0
	stats["ranged_exp"] = 0.0
	stats["woodcutting_exp"] = 0.0
	stats["mining_exp"] = 0.0
