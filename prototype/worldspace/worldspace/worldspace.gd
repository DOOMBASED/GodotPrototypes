# worldspace.gd
class_name Worldspace extends Node2D

@export var resource: WorldspaceResource
@onready var items: Node2D = $Items
var world_items: Array[Item]

func _ready() -> void:
	Global.set_worldspace(self)
	Inventory.connect("item_added", _on_item_added)
	Inventory.connect("item_dropped", _on_item_dropped)
	_get_world_items()

func _get_world_items() -> void:
	world_items.clear()
	for item in items.get_children():
		if item.is_in_group("Item"):
			world_items.append(item)

func _on_item_added(item: ItemResource, _iterator: int) -> void:
	for i in range(world_items.size()):
		if world_items[i] != null and world_items[i].resource.id == item.id and world_items[i].resource.init == item.init:
			world_items[i] = null
			item.init = Vector2.ZERO
	for nul in world_items:
		if not is_instance_valid(nul):
			world_items.erase(nul)

func _on_item_dropped(item: Item) -> void:
	world_items.append(item)
