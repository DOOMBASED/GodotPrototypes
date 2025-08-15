# inventory_ui_menu.gd
extends PanelContainer

var current_iterator: int = -1
var current_item: ItemResource = null
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var effect_label: Label = $MarginContainer/VBoxContainer/EffectLabel
@onready var assign_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/AssignButton
@onready var use_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/UseButton
@onready var equip_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/EquipButton
@onready var split_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/SplitButton
@onready var drop_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/DropButton

signal item_assigned(current_item: ItemResource)
signal item_equipped(current_iterator: int)

func _ready() -> void:
	_menu_hide()

func menu_show(item: ItemResource, iterator: int) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var offset := Vector2(8.0, 8.0)
	if mouse_position.y > Global.viewport.size.y - Inventory.inventory_ui.inventory_ui_hotbar.size.y:
		return
	current_item = item
	current_iterator = iterator
	name_label.text = item.name
	drop_button.show()
	if item is ItemUseable:
		effect_label.text = str(item.effect, " +" , item.magnitude)
		effect_label.show()
		assign_button.show()
		use_button.show()
	if item is ItemEquipment:
		effect_label.text = str(item.equip_effect, " +", item.equip_effect_magnitude)
		effect_label.show()
		assign_button.show()
		equip_button.show()
	if current_item.quantity >= 2:
		split_button.disabled = false
		split_button.show()
	position = mouse_position - offset
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func _menu_hide() -> void:
	hide()
	effect_label.hide()
	assign_button.hide()
	use_button.hide()
	equip_button.hide()
	split_button.hide()
	drop_button.hide()
	position = Vector2(-size.x, -size.y)
	size = custom_minimum_size
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_assign_button_pressed() -> void:
	if Global.player.animation_manager.current_state != 3:
		var assigned = Inventory.inventory_ui.inventory_ui_hotbar.hotbar_assignment_check(current_item)
		if current_item != null:
			if assigned:
				if current_item is ItemEquipment:
					if current_item.equip_anim == current_item.equip_anim:
						Global.player.animation_manager.equip_anim = ""
				Inventory.item_remove_from_hotbar(current_item.id)
				if assign_button.text == "UNASSIGN":
					assign_button.text = "ASSIGN"
				assigned = false
			elif !assigned:
				Inventory.item_add(current_item, false, true)
				if assign_button.text == "ASSIGN":
					assign_button.text = "UNASSIGN"
				assigned = true
			item_assigned.emit(current_item)
			Inventory.inventory_updated.emit()

func _on_use_button_pressed() -> void:
	if not Inventory.cooldown:
		if current_item != null and current_item is ItemUseable:
			if current_item.quantity > 1:
				Effects.item_effect(current_item)
				use_button.release_focus()
				Inventory.item_cooldown_timer()
			else:
				Effects.item_effect(current_item)
				current_item = null
				_menu_hide()
		else:
			Global.set_debug_text(str(current_item.name, " is not a useable item"))
	use_button.release_focus()

func _on_equip_button_pressed() -> void:
	if Global.player.animation_manager.current_state != 3:
		if current_item != null and current_item is ItemEquipment:
			Global.player.animation_manager.equip_anim = current_item.equip_anim
			Global.player.weapon_manager.equipped_item = current_item
			if not Inventory.inventory_ui.inventory_ui_hotbar.hotbar_assignment_check(current_item):
				Inventory.item_add(current_item, false, true)
			if assign_button.text == "ASSIGN":
				assign_button.text = "UNASSIGN"
			item_equipped.emit(current_iterator)
			item_assigned.emit(current_item)
			Inventory.inventory_updated.emit()

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
	if not Inventory.cooldown and Global.player.animation_manager.current_state != 3:
		if current_item.quantity > 1:
			Inventory.item_remove(current_item, current_item.slot)
			drop_button.release_focus()
			Inventory.item_cooldown_timer()
		else:
			if current_item is ItemEquipment:
				if current_item.equip_anim == Global.player.animation_manager.equip_anim:
					var current_slot: Panel = Inventory.inventory_ui.inventory_grid.get_child(current_iterator)
					current_slot.self_modulate = Color.WHITE
					if Global.player.animation_manager.current_state == 3:
						Global.player.animation_manager.current_state = 0
						await Global.player.animation_manager.animation_player.animation_finished
					Global.player.animation_manager.equip_anim = ""
					Global.player.weapon_manager.equipped_item = null
			Inventory.item_remove(current_item, current_item.slot)
			current_item = null
			Inventory.item_cooldown_timer()
			_menu_hide()
		Inventory.inventory_updated.emit()
	drop_button.release_focus()

func _on_menu_mouse_exited() -> void:
	_menu_hide()
