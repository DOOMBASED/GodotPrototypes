# _inventory_ui_slot.gd
extends Panel

var resource: ItemResource = null

@onready var inventory_ui_menu: PanelContainer = $InventoryUIMenu
@onready var sprite: Sprite2D = $MarginContainer/CenterContainer/Sprite
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
@onready var name_label: Label = $InventoryUIMenu/MarginContainer/VBoxContainer/NameLabel
@onready var effect_label: Label = $InventoryUIMenu/MarginContainer/VBoxContainer/EffectLabel
@onready var use_button: Button = $InventoryUIMenu/MarginContainer/VBoxContainer/ButtonContainer/UseButton
@onready var drop_button: Button = $InventoryUIMenu/MarginContainer/VBoxContainer/ButtonContainer/DropButton

signal drag_start(slot: Panel)
signal drag_release

func _menu_show(item: ItemResource) -> void:
	inventory_ui_menu.process_mode = Node.PROCESS_MODE_INHERIT
	var mouse_position: Vector2 = get_global_mouse_position()
	var offset := Vector2(8.0, 8.0)
	name_label.text = item.name
	drop_button.show()
	if item is ItemUseable:
		effect_label.text = str(item.effect, " +" , item.magnitude)
		effect_label.show()
		use_button.show()
	inventory_ui_menu.position = mouse_position - offset
	inventory_ui_menu.show()

func _menu_hide() -> void:
	inventory_ui_menu.process_mode = Node.PROCESS_MODE_DISABLED
	inventory_ui_menu.hide()
	drop_button.hide()
	effect_label.hide()
	use_button.hide()
	inventory_ui_menu.size = inventory_ui_menu.custom_minimum_size

func _on_slot_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not Global.player.recent_pickup:
			if resource != null:
				if event.button_index == MOUSE_BUTTON_RIGHT:
					_menu_show(resource)
				if event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_ALT):
					Inventory.item_remove(resource, int(name))
				elif event.button_index == MOUSE_BUTTON_LEFT:
					if event.is_pressed():
						drag_start.emit(self)
					else:
						drag_release.emit()

func _on_use_button_pressed() -> void:
	if resource != null and resource is ItemUseable:
		Effects.item_effect(resource, int(name))
		if resource == null:
			_menu_hide()
	else:
		Global.set_debug_text(str(resource.name, " is not a useable item"))

func _on_drop_button_pressed() -> void:
	Inventory.item_remove(resource, int(name))
	if resource == null:
		_menu_hide()

func _on_menu_mouse_exited() -> void:
	_menu_hide()
