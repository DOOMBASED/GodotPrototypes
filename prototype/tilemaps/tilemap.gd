# tilemap.gd
extends Node2D

@onready var land: TileMapLayer = $Land
@onready var groundcover: TileMapLayer = $Groundcover
@onready var soil: TileMapLayer = $Soil
@onready var crops: TileMapLayer = $Crops

func _ready() -> void:
	await Global.worldspace_set
	Global.worldspace.set_tilemap(self)
	Global.time_is_dawn.connect(_at_dawn_hour)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if Global.worldspace.equipped_seed != null:
			terrain_plant(Global.worldspace.equipped_seed_atlas)

func _terrain_get_position() -> Vector2i:
	var tile_data: TileData = null
	if Global.player.animation_manager.equip_anim == "" and Global.worldspace.equipped_seed != null:
		tile_data = soil.get_cell_tile_data(soil.local_to_map(Global.player.global_position))
		var tile_pos = soil.local_to_map(Global.player.global_position)
		if tile_data != null and tile_data.get_custom_data("soil"):
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Hoe":
		tile_data = land.get_cell_tile_data(land.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("till"):
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Shovel":
		tile_data = land.get_cell_tile_data(land.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("path"):
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Sickle":
		tile_data = groundcover.get_cell_tile_data(groundcover.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("harvest"):
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
	return Vector2i.MAX

func terrain_plant(atlas_coords: Vector2i) -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		for i: int in range(Global.worldspace.planted_crops.size()):
			if Global.worldspace.planted_crops[i] == terrain_pos:
				return
		Global.worldspace.planted_crops.append(terrain_pos)
		crops.set_cell(terrain_pos, 5, atlas_coords)
		Inventory.item_remove(Global.worldspace.equipped_seed, Global.worldspace.equipped_seed.slot)
		if Global.worldspace.equipped_seed.quantity <= 0:
			Global.worldspace.equipped_seed = null
			Global.worldspace.equipped_seed_atlas = Vector2i.MAX

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

func _at_dawn_hour() -> void:
	print("dawn")
