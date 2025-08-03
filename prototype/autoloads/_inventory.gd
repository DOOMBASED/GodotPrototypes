# _inventory.gd
extends Node

var inventory: Array[ItemResource] = []
var inventory_ui: Control = null
var inventory_size: int = 8
var inventory_max: int = 16
var inventory_full: bool = false

const item_scene: PackedScene = preload("res://item/item/item.tscn")

signal item_added(item: ItemResource, iterator: int)
signal item_dropped(item: Item)
signal inventory_updated

func _ready() -> void:
	inventory.resize(inventory_size)

func set_inventory_ui(current_inventory_ui: Control) -> void:
	inventory_ui = current_inventory_ui

func item_add(item: ItemResource) -> bool:
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i].id == item.id:
			if inventory[i].quantity < item.maximum:
				inventory[i].quantity += item.count
				if inventory[i].quantity > item.maximum:
					item.count = inventory[i].quantity - item.maximum
					inventory[i].quantity = item.maximum
					item_added.emit(item, i)
					return item_add(item)
				else:
					item_added.emit(item, i)
					return true
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			item.quantity = item.count
			item_added.emit(item, i)
			inventory_updated.emit()
			_inventory_check()
			return true
	_inventory_check()
	return false

func item_remove(item: ItemResource, slot_index: int) -> bool:
	if item:
		Inventory.inventory[slot_index].quantity -= item.count
		if Inventory.inventory[slot_index].quantity <= 0:
			Inventory.inventory[slot_index] = null
			Inventory.inventory_full = false
		Inventory.inventory_updated.emit()
		if Effects.should_use:
			Effects.should_use = false
		else:
			item_drop(item)
		return true
	return false

func item_swap(index1: int, index2: int) -> bool:
	if index1 < 0 || index1 > inventory.size() || index2 > inventory.size():
		return false
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	inventory_updated.emit()
	return true

func item_drop(item: ItemResource) -> bool:
	if item:
		var instance: Item = item_scene.instantiate()
		var distance: int = 32
		var radius := Vector2(-randi_range(-distance, distance), -randi_range(-distance, distance))
		instance.resource = item.duplicate()
		instance.position = Global.player.position + radius 
		instance.resource.init = instance.position
		instance.name = str(item.name, "_" , instance.get_instance_id())
		get_tree().get_first_node_in_group("Worldspace").items.add_child(instance)
		item_dropped.emit(instance)
		Global.player.recent_pickup = true
		Global.player.recent_pickup_time = Global.player.recent_pickup_limit / 2.0
		return true
	return false

func _inventory_check() -> void:
	inventory_full = inventory.count(null) == 0
	if inventory_full:
		Global.set_debug_text("Inventory: Inventory full, item not added.")
