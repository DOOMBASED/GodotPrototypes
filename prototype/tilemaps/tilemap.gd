# tilemap.gd
extends Node2D

@onready var land: TileMapLayer = $Land
@onready var groundcover: TileMapLayer = $Groundcover
@onready var soil: TileMapLayer = $Soil
@onready var watered: TileMapLayer = $Watered
@onready var crops: TileMapLayer = $Crops
@export var seed_types: Array = []

func _ready() -> void:
	await Global.worldspace_set
	Global.worldspace.set_tilemap(self)
	Global.time_is_dawn.connect(_at_time_change)
	Global.time_is_dusk.connect(_at_time_change)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if Global.player.animation_manager.equip_anim == "" and Global.worldspace.equipped_seed != null:
			terrain_plant(Global.worldspace.equipped_seed_atlas)

func _terrain_get_position() -> Vector2i:
	var tile_data: TileData = null
	if Global.player.animation_manager.equip_anim == "" and Global.worldspace.equipped_seed != null:
		if Global.worldspace.equipped_seed.seed_type == "Grass":
			return Vector2i.MAX
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
		tile_data = crops.get_cell_tile_data(crops.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_data_ground = groundcover.get_cell_tile_data(groundcover.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("harvest"):
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
		if tile_data == null and tile_data_ground != null:
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
	if Global.player.animation_manager.equip_anim == "Water":
		tile_data = soil.get_cell_tile_data(soil.local_to_map(Global.player.weapon_manager.weapon_point.global_position))
		var tile_pos = Global.player.weapon_manager.weapon_point.global_position
		if tile_data != null and tile_data.get_custom_data("soil"):
			Stats.exp_stats["Farming"] += Stats.base_exp_rate * Global.player.weapon_manager.equipped_item.exp_multiplier
			Stats.exp_updated.emit()
			return tile_pos
	return Vector2i.MAX

func terrain_plant(atlas_coords: Vector2i) -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		for i: int in range(Global.worldspace.planted_crops.size()):
			if Global.worldspace.planted_crops[i].planted_pos == terrain_pos:
				return
		var planted_crop: ItemSeed = Global.worldspace.equipped_seed.duplicate()
		planted_crop.planted_pos = terrain_pos
		planted_crop.planted = true
		if Global.time_in_hours <= 12.0:
			planted_crop.planted_hour = 12.0
		if Global.time_in_hours > 12.0:
			planted_crop.planted_hour = 0.0
		planted_crop.quantity = 0
		Global.worldspace.planted_crops.append(planted_crop)
		crops.set_cell(terrain_pos, 5, atlas_coords)
		Global.worldspace.equipped_seed.planted = true
		Inventory.item_remove(Global.worldspace.equipped_seed, Global.worldspace.equipped_seed.slot, false)
		if Global.worldspace.equipped_seed.quantity <= 0:
			Global.player.weapon_manager.sprite.texture = null
			Global.worldspace.equipped_seed = null
			Global.worldspace.equipped_seed_atlas = Vector2i.MAX

func terrain_harvest() -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)
		var chance: int = randi_range(0, 100)
		if chance > 50:
			var new_seed = Inventory.item_scene.instantiate()
			if chance < 75:
				new_seed.resource = seed_types.pick_random()
			else:
				new_seed.resource = seed_types[0]
			Global.worldspace.items.add_child(new_seed)
			new_seed.global_position = terrain_pos
			new_seed.sprite.texture = new_seed.resource.seed_texture

func terrain_path(terrain_set: int, terrain: int) -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		var to_update: Array = [land.local_to_map(terrain_pos)]
		groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)
		land.set_cell(land.local_to_map(terrain_pos), -1)
		land.set_cells_terrain_connect(to_update, terrain_set, terrain)

func terrain_till(terrain_set: int, terrain: int) -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		var to_update: Array = [land.local_to_map(terrain_pos)]
		groundcover.set_cell(groundcover.local_to_map(terrain_pos), -1)
		soil.set_cell(land.local_to_map(terrain_pos), -1)
		soil.set_cells_terrain_connect(to_update, terrain_set, terrain)

func terrain_water(terrain_set: int, terrain: int) -> void:
	var terrain_pos = _terrain_get_position()
	if terrain_pos != Vector2i.MAX:
		var to_update: Array = [watered.local_to_map(terrain_pos)]
		watered.set_cells_terrain_connect(to_update, terrain_set, terrain)

func _at_time_change() -> void:
	for i: int in range(Global.worldspace.planted_crops.size()):
		if Global.worldspace.planted_crops[i].seed_atlas < Global.worldspace.planted_crops[i].seed_atlas_final:
			if Global.time_in_hours - Global.worldspace.planted_crops[i].planted_hour >= 6:
				var terrain_pos = Global.worldspace.planted_crops[i].planted_pos
				var tile_data = watered.get_cell_tile_data(Global.worldspace.planted_crops[i].planted_pos)
				Global.worldspace.planted_crops[i].seed_atlas.x += 1
				crops.set_cell(terrain_pos, 5, Global.worldspace.planted_crops[i].seed_atlas)
				if tile_data != null and tile_data.get_custom_data("watered"):
					Global.worldspace.planted_crops[i].times_watered += 1
				if Global.time_in_hours <= 12.0:
					Global.worldspace.planted_crops[i].planted_hour = 12.0
				if Global.time_in_hours > 12.0:
					Global.worldspace.planted_crops[i].planted_hour = 0.0
		elif Global.worldspace.planted_crops[i].seed_atlas == Global.worldspace.planted_crops[i].seed_atlas_final:
			if Global.worldspace.planted_crops[i].planted == true:
				var harvestable: Harvestable = Global.worldspace.planted_crops[i].harvestable.instantiate()
				harvestable.global_position = land.map_to_local(Global.worldspace.planted_crops[i].planted_pos)
				harvestable.name = str("Harvestable", harvestable.resource.name, harvestable.get_instance_id())
				harvestable.init_position = harvestable.global_position
				harvestable.harvested.connect(Global.worldspace.on_harvested)
				Global.worldspace.navigation_region.add_child(harvestable)
				Global.worldspace.planted_crops[i].planted = false
				crops.set_cell(Global.worldspace.planted_crops[i].planted_pos, -1)
	watered.clear()
	if not Global.worldspace.navigation_region.is_baking():
		Global.worldspace.navigation_region.bake_navigation_polygon(true)
