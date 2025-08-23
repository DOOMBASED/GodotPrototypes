# _stats.gd
extends Node

var exp_stats: Dictionary = {}
var kill_stats: Dictionary = {}

var base_exp_rate: float = 0.01

@warning_ignore("unused_signal")
signal kills_updated

func _ready() -> void:
	await Global.player_set
	_init_stats_exp()
	_init_stats_kills()

func _init_stats_exp() -> void:
	exp_stats["health_exp"] = 0.0
	exp_stats["stamina_exp"] = 0.0
	exp_stats["magic_exp"] = 0.0
	exp_stats["melee_exp"] = 0.0
	exp_stats["ranged_exp"] = 0.0
	exp_stats["woodcutting_exp"] = 0.0
	exp_stats["mining_exp"] = 0.0

func _init_stats_kills() -> void:
	kill_stats["null"] = 0
