# _inventory_ui_slot.gd
extends Panel

var resource: ItemResource = null
@onready var sprite: Sprite2D = $MarginContainer/CenterContainer/Sprite
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
var init_position := Vector2.ZERO
var assigned: bool = false

signal drag_start(slot: Panel)
signal drag_release

func _ready() -> void:
	Inventory.inventory_ui.menu.item_assigned.connect(_on_assigned)
	Inventory.inventory_ui.menu.item_equipped.connect(_on_item_equipped)

func _slot_set_assignment(item: ItemResource) -> void:
	assigned = Inventory.inventory_ui.inventory_ui_hotbar.hotbar_assignment_check(item)

func _on_slot_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if resource != null:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if Inventory.inventory_ui.inventory_ui_hotbar.hotbar_assignment_check(resource):
					Inventory.inventory_ui.menu.assign_button.text = "UNASSIGN"
				else:
					Inventory.inventory_ui.menu.assign_button.text = "ASSIGN"
				Inventory.inventory_ui.menu.menu_show(resource, int(self.name))
			if event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_ALT):
				Inventory.item_remove(resource, int(name))
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					drag_start.emit(self)
				else:
					drag_release.emit()

func _on_item_equipped(iterator: int) -> void:
	if resource is ItemEquipment:
		if iterator == int(name):
			quantity_label.text = "E"
			self_modulate = Color.GREEN
		else:
			quantity_label.text = ""
			self_modulate = Color.WHITE

func _on_assigned(item: ItemResource) -> void:
	_slot_set_assignment(item)
