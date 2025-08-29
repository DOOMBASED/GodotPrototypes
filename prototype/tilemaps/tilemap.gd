# tilemap.gd
extends Node2D

@onready var land: TileMapLayer = $Land
@onready var groundcover: TileMapLayer = $Groundcover
@onready var soil: TileMapLayer = $Soil

func _ready() -> void:
	await Global.worldspace_set
	Global.worldspace.set_tilemap(self)

func _terrain_get_position() -> Vector2:
	var tile_data: TileData = null
	if Global.player.animation_manager.equip_anim == "Hoe":
		tile_data = land.get_cell_tile_data(land.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("till"):
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Shovel":
		tile_data = land.get_cell_tile_data(land.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("path"):
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Sickle":
		tile_data = groundcover.get_cell_tile_data(groundcover.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("harvest"):
			return tile_pos
	return Vector2.INF

func terrain_harvest() -> void:
	var terrain_pos = _terrain_get_position()
	groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)

func terrain_path(terrain_set: int, terrain: int) -> void:
	var terrain_pos = _terrain_get_position()
	var to_update: Array = [land.local_to_map(terrain_pos)]
	groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)
	land.set_cell(land.local_to_map(terrain_pos), -1)
	land.set_cells_terrain_connect(to_update, terrain_set, terrain)

func terrain_till(terrain_set: int, terrain: int) -> void:
	var terrain_pos = _terrain_get_position()
	var to_update: Array = [land.local_to_map(terrain_pos)]
	groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)
	soil.set_cell(land.local_to_map(terrain_pos), -1)
	soil.set_cells_terrain_connect(to_update, terrain_set, terrain)
