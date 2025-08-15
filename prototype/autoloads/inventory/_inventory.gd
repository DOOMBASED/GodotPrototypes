# _inventory.gd
extends Node

var inventory: Array[ItemResource] = []
var hotbar_inventory: Array[ItemResource] = []
var inventory_ui: Control = null
var hotbar_ui: PanelContainer = null
var inventory_size: int = 8
var inventory_max: int = 24
var hotbar_size: int = 9
var hotbar_max: int = 9
var cooldown_time: float = 0.25
var recent_pickup_limit: float = 48.0
var recent_pickup_time: float = 0.0
var cooldown: bool
var recent_pickup: bool = false
var inventory_full: bool = false

const item_scene: PackedScene = preload("res://items/item/item.tscn")

signal inventory_ui_set
signal item_added(item: ItemResource, iterator: int)
signal item_dropped(item: Item)
signal inventory_updated

func _ready() -> void:
	inventory.resize(inventory_size)
	hotbar_inventory.resize(hotbar_size)

func _process(_delta: float) -> void:
	if recent_pickup:
		_check_pickup()

func set_ui(current_inventory_ui: Control) -> void:
	inventory_ui = current_inventory_ui
	inventory_ui_set.emit()

func set_hotbar(current_hotbar_ui: PanelContainer):
	hotbar_ui = current_hotbar_ui

func item_add(item: ItemResource, split: bool = false, assign: bool = false) -> bool:
	var assigned: bool = false
	if assign:
		for i in range(hotbar_inventory.size()):
			assigned = _item_assign_hotbar(item)
			inventory_updated.emit()
			item_added.emit(item, i)
			return true
		return false
	if not split and not assigned:
		for i: int in range(inventory.size()):
			if inventory[i] != null and inventory[i].id == item.id:
				if inventory[i].quantity < item.maximum:
					inventory[i].quantity += item.count
					inventory[i].slot = i
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
			inventory[i].slot = i
			item_added.emit(item, i)
			recent_pickup_time = 0.0
			inventory_updated.emit()
			_check_inventory()
			return true
	_check_inventory()
	return false

func item_swap(_inventory: Array, index1: int, index2: int) -> bool:
	if index1 < 0 or index1 > _inventory.size() or index2 > _inventory.size():
		return false
	var temp_item: ItemResource = _inventory[index1]
	var temp_slot: int = _inventory[index1].slot
	if _inventory == Inventory.inventory:
		if _inventory[index2] != null:
			_inventory[index1].slot = _inventory[index2].slot
			_inventory[index2].slot = temp_slot
		else:
			_inventory[index1].slot = index2
	_inventory[index1] = _inventory[index2]
	_inventory[index2] = temp_item
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

func item_remove(item: ItemResource, slot_index: int) -> bool:
	if item != null:
		Inventory.inventory[slot_index].quantity -= item.count
		if Inventory.inventory[slot_index].quantity <= 0:
			_item_unassign_hotbar(item)
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

func item_remove_from_hotbar(id: String) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i].id == id:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func item_cooldown_timer() -> void:
	cooldown = true
	await get_tree().create_timer(cooldown_time).timeout
	cooldown = false

func _item_assign_hotbar(item: ItemResource) -> bool:
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false

func _item_unassign_hotbar(item: ItemResource) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i].id == item.id:
			if hotbar_inventory[i].quantity <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

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
