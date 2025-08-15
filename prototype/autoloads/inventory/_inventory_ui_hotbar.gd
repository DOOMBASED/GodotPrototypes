# _inventory_ui_hotbar.gd
extends PanelContainer

@onready var hotbar_container: HBoxContainer = $MarginContainer/HotbarContainer

var current_slot: Panel = null

func _ready() -> void:
	Inventory.set_hotbar(self)
	Inventory.inventory_updated.connect(_on_hotbar_updated)
	await Inventory.inventory_ui_set
	for i: int in range(Inventory.hotbar_size):
		_slot_new(str(i))

func _process(_delta: float) -> void:
	if current_slot != null:
		var mouse_position: Vector2 = get_global_mouse_position()
		var offset := Vector2(current_slot.size / 2)
		current_slot.global_position = mouse_position - offset

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("show_inventory"):
			_hotbar_toggle()
		if visible:
			for i in range(Inventory.hotbar_size):
					if Input.is_action_just_pressed(str(i + 1)):
						_hotbar_use_item(i)
						break

func hotbar_assignment_check(item: ItemResource) -> bool:
	return item in Inventory.hotbar_inventory

func _hotbar_toggle() -> void:
	self.visible = not self.visible

func _hotbar_use_item(slot_index: int) -> void:
	if not Inventory.cooldown:
		if slot_index < Inventory.hotbar_inventory.size():
			var item = Inventory.hotbar_inventory[slot_index]
			if item != null:
				if item is ItemUseable:
					Effects.item_effect(item)
				if item is ItemEquipment:
					_hotbar_equip_item(item)
		Inventory.item_cooldown_timer()

func _hotbar_equip_item(item: ItemResource) -> void:
	if not Inventory.cooldown:
		var effect: String = str(item.equip_anim)
		if Global.player.animation_manager.equip_anim == "":
			Global.player.animation_manager.equip_anim = effect
			Global.player.weapon_manager.equipped_item = item
		elif Global.player.animation_manager.equip_anim == effect:
			Global.player.animation_manager.equip_anim = ""
			Global.player.weapon_manager.equipped_item = null
		elif Global.player.animation_manager.equip_anim != "" and Global.player.animation_manager.equip_anim != effect:
			Global.player.animation_manager.equip_anim = ""
			Global.player.weapon_manager.equipped_item = null
			_hotbar_equip_item(item)
		Inventory.inventory_updated.emit()
		Inventory.item_cooldown_timer()

func _slot_new(new_name: String) -> void:
	var new_slot: Panel = Inventory.inventory_ui.slot_scene.instantiate()
	new_slot.drag_start.connect(_on_drag_start)
	new_slot.drag_release.connect(_on_drag_release)
	hotbar_container.add_child(new_slot)
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
	for i: int in range(hotbar_container.get_child_count()):
		if hotbar_container.get_child(i) == slot:
			return i
	return -1

func _get_slot_target() -> Panel:
	var mouse_position: Vector2 = get_global_mouse_position()
	for slot: Panel in hotbar_container.get_children():
		var slot_rect := Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position) and slot != current_slot:
			slot.init_position = slot.global_position
			return slot
	return null

func _on_drag_start(dragged_slot: Panel) -> void:
	dragged_slot.self_modulate = Color.WHITE
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
	if current_slot.resource is ItemEquipment:
		if current_slot.resource.equip_anim == Global.player.animation_manager.equip_anim:
			current_slot.self_modulate = Color.GREEN
			current_slot.quantity_label.text = "E"
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
	if slot_1.resource is ItemEquipment:
		if slot_1.resource.equip_anim == Global.player.animation_manager.equip_anim:
			slot_1.quantity_label.text = ""
			slot_1.self_modulate = Color.WHITE
			if slot_2.resource is ItemEquipment:
				slot_2.quantity_label.text = "E"
				slot_2.self_modulate = Color.GREEN
		if slot_2.resource is ItemEquipment:
			if slot_2.resource.equip_anim == Global.player.animation_manager.equip_anim:
				slot_2.quantity_label.text = ""
				slot_2.self_modulate = Color.WHITE
				if slot_1.resource is ItemEquipment:
					slot_1.quantity_label.text = "E"
					slot_1.self_modulate = Color.GREEN
	if slot_1_index == -1 or slot_2_index == -1:
		return
	else:
		if Inventory.item_swap(Inventory.hotbar_inventory, slot_1_index, slot_2_index):
			_on_hotbar_updated()

func _on_hotbar_updated() -> void:
	if Inventory.hotbar_inventory.size() > hotbar_container.get_child_count():
		_slot_new(str(Inventory.hotbar_inventory.size() - 1))
	for i: int in range(Inventory.hotbar_inventory.size()):
		for slot: Panel in hotbar_container.get_children():
			if Inventory.hotbar_inventory[i] != null:
				if i == slot.get_index():
					slot.sprite.texture = Inventory.hotbar_inventory[i].texture
					if slot.resource != null:
						if slot.resource is not ItemEquipment:
							slot.quantity_label.text = str(slot.resource.quantity)
							slot.self_modulate = Color.WHITE
						else:
							if slot.resource.equip_anim == Global.player.animation_manager.equip_anim:
								slot.quantity_label.text = "E"
								slot.self_modulate = Color.GREEN
							else:
								slot.quantity_label.text = ""
								slot.self_modulate = Color.WHITE
					slot.resource = Inventory.hotbar_inventory[i]
			else:
				if i == slot.get_index():
					slot.self_modulate = Color.WHITE
					slot.sprite.texture = null
					slot.quantity_label.text = ""
					slot.resource = null
