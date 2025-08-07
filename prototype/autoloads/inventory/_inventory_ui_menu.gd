# inventory_ui_menu.gd
extends PanelContainer

var current_iterator: int = -1
var current_item: ItemResource = null
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var effect_label: Label = $MarginContainer/VBoxContainer/EffectLabel
@onready var use_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/UseButton
@onready var split_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/SplitButton
@onready var drop_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/DropButton

func _ready() -> void:
	_menu_hide()

func menu_show(item: ItemResource, iterator: int) -> void:
	current_item = item
	current_iterator = iterator
	var mouse_position: Vector2 = get_global_mouse_position()
	var offset := Vector2(8.0, 8.0)
	name_label.text = item.name
	drop_button.show()
	if item is ItemUseable:
		effect_label.text = str(item.effect, " +" , item.magnitude)
		effect_label.show()
		use_button.show()
	if current_item.quantity >= 2:
		split_button.disabled = false
		split_button.show()
	position = mouse_position - offset
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func _menu_hide() -> void:
	hide()
	drop_button.hide()
	effect_label.hide()
	split_button.hide()
	use_button.hide()
	position = Vector2(-size.x, -size.y)
	size = custom_minimum_size
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_use_button_pressed() -> void:
	if not Inventory.cooldown:
		if current_item != null and current_item is ItemUseable:
			if current_item.quantity > 1:
				Effects.item_effect(current_item, current_iterator)
				use_button.release_focus()
				Inventory.item_timer()
			else:
				Effects.item_effect(current_item, current_iterator)
				current_item = null
				_menu_hide()
		else:
			Global.set_debug_text(str(current_item.name, " is not a useable item"))
	use_button.release_focus()

func _on_split_button_pressed() -> void:
	if not Inventory.inventory_full:
		if current_item.quantity >= 2:
			var instance: ItemResource = current_item.duplicate(true)
			instance.quantity = 0
			Inventory.item_add(instance, true)
			current_item.quantity -= 1
			Inventory.inventory_updated.emit()
			if current_item.quantity < 2:
				split_button.disabled = true
	else:
		Global.set_debug_text("Inventory full, stack not split.")

func _on_drop_button_pressed() -> void:
	if not Inventory.cooldown:
		if current_item.quantity > 1:
			Inventory.item_remove(current_item, current_iterator)
			drop_button.release_focus()
			Inventory.item_timer()
		else:
			Inventory.item_remove(current_item, current_iterator)
			current_item = null
			Inventory.item_timer()
			_menu_hide()
	drop_button.release_focus()

func _on_menu_mouse_exited() -> void:
	_menu_hide()
