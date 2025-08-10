# _inventory_ui.gd
extends Control

@onready var menu: PanelContainer = $InventoryUIMenu
@onready var inventory: PanelContainer = $Inventory
@onready var inventory_grid: GridContainer = $Inventory/MarginContainer/VBoxContainer/InventoryGrid
var current_slot: Panel = null

const slot_scene: PackedScene = preload("res://autoloads/inventory/_inventory_ui_slot.tscn")

func _ready() -> void:
	Inventory.set_ui(self)
	Inventory.connect("item_added", _on_item_added)
	for i: int in Inventory.inventory_size:
		_slot_new(str(Inventory.inventory.size()))
	_inventory_toggle()

func _process(_delta: float) -> void:
	if current_slot != null:
		var mouse_position: Vector2 = get_global_mouse_position()
		var offset := Vector2(current_slot.size / 2)
		current_slot.global_position = mouse_position - offset

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_inventory"):
			_inventory_toggle()

func _inventory_toggle() -> void:
	inventory.visible = not inventory.visible

func _slot_new(new_name: String) -> void:
	var new_slot: Panel = slot_scene.instantiate()
	new_slot.drag_start.connect(_on_drag_start)
	new_slot.drag_release.connect(_on_drag_release)
	inventory_grid.add_child(new_slot)
	new_slot.name = new_name

func _slot_check(target_slot: Panel) -> void:
	var current_slot_index: int = _get_slot_index(current_slot)
	if current_slot.resource.id == target_slot.resource.id:
		if target_slot.resource.quantity != target_slot.resource.maximum:
			target_slot.resource.quantity = current_slot.resource.quantity + target_slot.resource.quantity
			current_slot.resource.quantity = 0
			if target_slot.resource.quantity > target_slot.resource.maximum:
				current_slot.resource.quantity = target_slot.resource.quantity - target_slot.resource.maximum
				target_slot.resource.quantity = target_slot.resource.maximum
			if current_slot.resource.quantity <= 0:
				Inventory.item_remove(current_slot.resource, current_slot_index)
	_on_drag_end(current_slot, target_slot)

func _get_slot_index(slot: Panel) -> int:
	for i: int in range(inventory_grid.get_child_count()):
		if inventory_grid.get_child(i) == slot:
			return i
	return -1

func _get_slot_target() -> Panel:
	var mouse_position: Vector2 = get_global_mouse_position()
	for slot: Panel in inventory_grid.get_children():
		var slot_rect := Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position) and slot != current_slot:
			slot.init_position = slot.global_position
			return slot
	return null

func _on_drag_start(dragged_slot: Panel) -> void:
	dragged_slot.init_position = dragged_slot.global_position
	current_slot = dragged_slot
	current_slot.z_index = 1

func _on_drag_release() -> void:
	var target_slot: Panel = _get_slot_target()
	if target_slot and current_slot != target_slot:
		if current_slot.resource != null and target_slot.resource != null:
			_slot_check(target_slot)
		else:
			_on_drag_end(current_slot, target_slot)
	current_slot.global_position = current_slot.init_position
	current_slot.z_index = 0
	current_slot = null

func _on_drag_end(slot_1: Panel, slot_2: Panel) -> void:
	var slot_1_index: int = _get_slot_index(slot_1)
	var slot_2_index: int = _get_slot_index(slot_2)
	slot_1.z_index = 0
	slot_2.z_index = 0
	slot_1.global_position = slot_1.init_position
	slot_2.global_position = slot_2.init_position
	if slot_1_index == -1 or slot_2_index == -1:
		return
	else:
		if Inventory.item_swap(slot_1_index, slot_2_index):
			_on_inventory_updated()

func _on_item_added(item: ItemResource, iterator: int) -> void:
	if item != null:
		if item.maximum == 1:
			inventory_grid.get_child(iterator).quantity_label.hide()
		elif item.maximum > 1:
			inventory_grid.get_child(iterator).quantity_label.text = str(Inventory.inventory[iterator].quantity)

func _on_inventory_updated() -> void:
	if Inventory.inventory.size() > inventory_grid.get_child_count():
		_slot_new(str(Inventory.inventory.size() - 1))
	for i: int in range(Inventory.inventory.size()):
		for slot: Panel in inventory_grid.get_children():
			if Inventory.inventory[i] != null:
				if i == slot.get_index():
					slot.sprite.texture = Inventory.inventory[i].texture
					slot.quantity_label.text = str(Inventory.inventory[i].quantity)
					slot.resource = Inventory.inventory[i]
			else:
				if i == slot.get_index():
					slot.sprite.texture = null
					slot.quantity_label.text = ""
					slot.resource = null
