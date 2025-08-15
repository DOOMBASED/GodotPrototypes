# worldspace.gd
class_name Worldspace extends Node2D

@export var resource: WorldspaceResource
@onready var navigation_region: NavigationRegion2D = $NavigationRegion
@onready var items: Node2D = $Items
var world_items: Array[Item]

func _ready() -> void:
	Global.set_worldspace(self)
	Inventory.item_added.connect(_on_item_added)
	Inventory.item_dropped.connect(_on_item_dropped)
	_get_world_items()

func _get_world_items() -> void:
	world_items.clear()
	for item: Item in items.get_children():
		world_items.append(item)

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
