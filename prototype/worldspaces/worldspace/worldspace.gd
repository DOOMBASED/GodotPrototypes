# worldspace.gd
class_name Worldspace extends Node2D

@export var resource: WorldspaceResource
var tilemap: Node2D = null
@onready var navigation_region: NavigationRegion2D = $NavigationRegion
@onready var lighting_color: CanvasModulate = $LightingColor
@onready var items: Node2D = $WorldItems
var world_items: Array[Item]
var world_harvestables: Array[Harvestable]

func _ready() -> void:
	Global.set_worldspace(self)
	for node: Harvestable in navigation_region.get_children():
		node.harvested.connect(_on_harvested)
	Inventory.item_added.connect(_on_item_added)
	Inventory.item_dropped.connect(_on_item_dropped)
	_get_world_items()

func set_tilemap(current_tilemap: Node2D) -> void:
	tilemap = current_tilemap

func _get_world_items() -> void:
	world_items.clear()
	for item: Item in items.get_children():
		world_items.append(item)
	for node: Harvestable in navigation_region.get_children():
		world_harvestables.append(node)

func _on_harvested(pos: Vector2) -> void:
	for i: int in range(world_harvestables.size()):
		if world_harvestables[i] != null:
			if world_harvestables[i].init_position == pos:
				world_harvestables[i] = null
	for nul: Node in world_harvestables:
		if not is_instance_valid(nul):
			world_harvestables.erase(nul)
	await get_tree().create_timer(0.5).timeout
	if not Global.worldspace.navigation_region.is_baking():
		Global.worldspace.navigation_region.bake_navigation_polygon(true)

func _on_item_added(item: ItemResource, _iterator: int) -> void:
	for i: int in range(world_items.size()):
		if world_items[i] != null:
			if world_items[i].resource.id == item.id and world_items[i].resource.init == item.init:
				world_items[i] = null
				item.init = Vector2.ZERO
	for nul: Node in world_items:
		if not is_instance_valid(nul):
			world_items.erase(nul)

func _on_item_dropped(item: Item) -> void:
	world_items.append(item)
