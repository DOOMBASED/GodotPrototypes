# _effects.gd
extends Node

var should_use: bool = false

func item_effect(item: ItemResource) -> void:
	if item is ItemUseable:
		should_use = false
		match item.effect:
			"Slot":
				if Inventory.inventory.size() >= Inventory.inventory_max:
					_item_not_used("Already at max Slots")
				else:
					_item_used(item, item.slot)
					_add_slots(item.magnitude)
			_:
				Global.set_debug_text("This item has no effect")
	else:
		Global.set_debug_text("This is not a useable item")

func _item_used(item: ItemResource, slot_index: int) -> void:
	should_use = true
	Inventory.item_remove(item, slot_index)

func _item_not_used(item_message: String) -> void:
	Global.set_debug_text(item_message)

func _add_slots(amount: int) -> void:
	Inventory.inventory.resize(Inventory.inventory.size() + amount)
	Inventory.inventory_full = false
	if Inventory.inventory.size() >= Inventory.inventory_max:
		Inventory.inventory.resize(Inventory.inventory_max)
	Inventory.inventory_updated.emit()
