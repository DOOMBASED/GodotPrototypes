# tilemap.gd
extends Node2D

@onready var land: TileMapLayer = $Land
@onready var groundcover: TileMapLayer = $Groundcover

func _ready() -> void:
	await Global.worldspace_set
	Global.worldspace.set_tilemap(self)

func replace_terrain(terrain_set: int, terrain: int) -> void:
	var to_update: Array = [land.local_to_map(Global.player.global_position + Global.player.movement_manager.facing)]
	groundcover.set_cell(land.local_to_map(Global.player.global_position + Global.player.movement_manager.facing), -1)
	land.set_cell(land.local_to_map(Global.player.global_position + Global.player.movement_manager.facing), -1)
	land.set_cells_terrain_connect(to_update, terrain_set, terrain)
