# _inventory_ui.gd
extends Control

@onready var inventory_grid: GridContainer = $Inventory/MarginContainer/InventoryGrid

var current_slot: Panel = null

const slot_scene: PackedScene = preload("res://autoloads/inventory_ui_slot.tscn")

func _ready() -> void:
	Inventory.set_inventory_ui(self)
	Inventory.connect("item_added", _on_item_added)
	for i in Inventory.inventory_size:
		_add_new_slot(str(Inventory.inventory.size()))

func _add_new_slot(new_name: String) -> void:
	var new_slot = slot_scene.instantiate()
	new_slot.drag_start.connect(_on_drag_start)
	new_slot.drag_release.connect(_on_drag_release)
	inventory_grid.add_child(new_slot)
	new_slot.name = new_name

func _get_slot_index(slot: Panel) -> int:
	for i in range(inventory_grid.get_child_count()):
		if inventory_grid.get_child(i) == slot:
			return i
	return -1

func _get_slot_target() -> Panel:
	var mouse_position: Vector2 = self.get_global_mouse_position()
	for slot in inventory_grid.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func _on_drag_start(dragged_slot: Panel) -> void:
	current_slot = dragged_slot

func _on_drag_release() -> void:
	var target_slot: Control = _get_slot_target()
	if target_slot && current_slot != target_slot:
		_on_drag_end(current_slot, target_slot)
	current_slot = null

func _on_drag_end(slot1: Control, slot2: Control) -> void:
	var slot1_index: int = _get_slot_index(slot1)
	var slot2_index: int = _get_slot_index(slot2)
	if slot1_index == -1 || slot2_index == -1:
		return
	else:
		if Inventory.item_swap(slot1_index, slot2_index):
			_on_inventory_updated()

func _on_item_added(item: ItemResource, iterator: int) -> void:
	if item != null:
		inventory_grid.get_child(iterator).quantity_label.text = str(Inventory.inventory[iterator].quantity)

func _on_inventory_updated() -> void:
	if Inventory.inventory.size() > inventory_grid.get_child_count():
		_add_new_slot(str(Inventory.inventory.size() - 1))
	for i in range(Inventory.inventory.size()):
		for child in inventory_grid.get_children():
			if Inventory.inventory[i] != null:
				if i == child.get_index():
					child.sprite.texture = Inventory.inventory[i].texture
					child.quantity_label.text = str(Inventory.inventory[i].quantity)
					child.resource = Inventory.inventory[i]
			else:
				if i == child.get_index():
					child.sprite.texture = null
					child.quantity_label.text = ""
					child.resource = null
