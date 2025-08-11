# _inventory.gd
extends Node

var inventory: Array[ItemResource] = []
var inventory_ui: Control = null
var inventory_size: int = 8
var inventory_max: int = 24
var cooldown_time: float = 0.25
var recent_pickup_limit: float = 48.0
var recent_pickup_time: float = 0.0
var cooldown: bool
var recent_pickup: bool = false
var inventory_full: bool = false

const item_scene: PackedScene = preload("res://items/item/item.tscn")

signal item_added(item: ItemResource, iterator: int)
signal item_dropped(item: Item)
signal inventory_updated

func _ready() -> void:
	inventory.resize(inventory_size)

func _process(_delta: float) -> void:
	if recent_pickup:
		_check_pickup()

func set_ui(current_inventory_ui: Control) -> void:
	inventory_ui = current_inventory_ui

func item_add(item: ItemResource, split: bool = false) -> bool:
	if not split:
		for i: int in range(inventory.size()):
			if inventory[i] != null and inventory[i].id == item.id:
				if inventory[i].quantity < item.maximum:
					inventory[i].quantity += item.count
					if inventory[i].quantity > item.maximum:
						item.count = inventory[i].quantity - item.maximum
						inventory[i].quantity = item.maximum
						item_added.emit(item, i)
						recent_pickup_time = 0.0
						return item_add(item)
					else:
						item_added.emit(item, i)
						recent_pickup_time = 0.0
						return true
	for i: int in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			item.quantity = item.count
			item_added.emit(item, i)
			recent_pickup_time = 0.0
			inventory_updated.emit()
			_check_inventory()
			return true
	_check_inventory()
	return false

func item_remove(item: ItemResource, slot_index: int) -> bool:
	if item != null:
		Inventory.inventory[slot_index].quantity -= item.count
		if Inventory.inventory[slot_index].quantity <= 0:
			Inventory.inventory[slot_index] = null
			Inventory.inventory_full = false
		Inventory.inventory_updated.emit()
		if Effects.should_use:
			Effects.should_use = false
			return true
		if item.quantity >= 0:
			item_drop(item)
		return true
	if Inventory.inventory_ui.menu.visible:
		Inventory.inventory_ui.menu.hide()
	return false

func item_swap(index1: int, index2: int) -> bool:
	if index1 < 0 or index1 > inventory.size() or index2 > inventory.size():
		return false
	var temp: ItemResource = inventory[index1]
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
		instance.resource.quantity = 0
		item_dropped.emit(instance)
		return true
	return false

func item_timer() -> void:
	cooldown = true
	await get_tree().create_timer(cooldown_time).timeout
	cooldown = false

func _check_inventory() -> void:
	inventory_full = inventory.count(null) == 0
	if inventory_full:
		Global.set_debug_text("Inventory full, item not added.")

func _check_pickup() -> void:
	recent_pickup_time += 1.0
	if recent_pickup_time == recent_pickup_limit - 1.0:
		inventory_updated.emit()
	if recent_pickup_time >= recent_pickup_limit:
		recent_pickup = false
