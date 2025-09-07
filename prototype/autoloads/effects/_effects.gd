# _effects.gd
extends Node

var should_use: bool = false

func item_effect(item: ItemResource) -> void:
	if item is ItemUseable:
		should_use = false
		match item.effect:
			"Hunger":
				if Global.player.stats_manager.hunger + item.magnitude < Global.player.stats_manager.hunger_max:
					Global.player.stats_manager.hunger += item.magnitude
					if Global.player.stats_manager.hunger > Global.player.stats_manager.hunger_max:
						Global.player.stats_manager.hunger = Global.player.stats_manager.hunger_max
					if item.secondary_effect != "":
						match item.secondary_effect:
							"Thirst":
								if Global.player.stats_manager.thirst + item.secondary_magnitude < Global.player.stats_manager.thirst_max:
									Global.player.stats_manager.thirst += item.secondary_magnitude
									if Global.player.stats_manager.thirst > Global.player.stats_manager.thirst_max:
										Global.player.stats_manager.thirst = Global.player.stats_manager.thirst_max
					_item_used(item, item.slot)
				else:
					_item_not_used("Already at max Hunger")
			"Thirst":
				if Global.player.stats_manager.thirst + item.magnitude < Global.player.stats_manager.thirst_max:
					Global.player.stats_manager.thirst += item.magnitude
					if Global.player.stats_manager.thirst > Global.player.stats_manager.thirst_max:
						Global.player.stats_manager.thirst = Global.player.stats_manager.thirst_max
					_item_used(item, item.slot)
				else:
					_item_not_used("Already at max Thirst")
			"Health":
				if Global.player.stats_manager.health < Global.player.stats_manager.health_max:
					Global.player.stats_manager.health += item.magnitude
					if Global.player.stats_manager.health > Global.player.stats_manager.health_max:
						Global.player.stats_manager.health = Global.player.stats_manager.health_max
					_item_used(item, item.slot)
				else:
					_item_not_used("Already at max Health")
			"Stamina":
				if Global.player.stats_manager.stamina < Global.player.stats_manager.stamina_max:
					Global.player.stats_manager.stamina += item.magnitude
					if Global.player.stats_manager.stamina > Global.player.stats_manager.stamina_max:
						Global.player.stats_manager.stamina = Global.player.stats_manager.stamina_max
					_item_used(item, item.slot)
				else:
					_item_not_used("Already at max Stamina")
			"Magic":
				if Global.player.stats_manager.magic < Global.player.stats_manager.magic_max:
					Global.player.stats_manager.magic += item.magnitude
					if Global.player.stats_manager.magic > Global.player.stats_manager.magic_max:
						Global.player.stats_manager.magic = Global.player.stats_manager.magic_max
					_item_used(item, item.slot)
				else:
					_item_not_used("Already at max Magic")
			"Light":
				if not Global.player.light.enabled:
					var timer_time: float
					timer_time = item.magnitude
					_item_used(item, item.slot)
					_light_on()
					await get_tree().create_timer(timer_time).timeout
					_light_off()
				else:
					_item_not_used("Light already on")
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
	Inventory.item_remove(item, slot_index, false)

func _item_not_used(item_message: String) -> void:
	Global.set_debug_text(item_message)

func _add_slots(amount: int) -> void:
	Inventory.inventory.resize(Inventory.inventory.size() + amount)
	Inventory.inventory_size += amount
	Inventory.inventory_full = false
	if Inventory.inventory.size() >= Inventory.inventory_max:
		Inventory.inventory.resize(Inventory.inventory_max)
	Inventory.inventory_updated.emit()

func _light_on() -> void:
	Global.player.light.enabled = true
	var light_tween: Tween = create_tween()
	light_tween.tween_property(Global.player.light, "texture_scale", 1.0, 0.25)

func _light_off() -> void:
	var light_tween: Tween = create_tween()
	light_tween.tween_property(Global.player.light, "texture_scale", 0.0, 0.25)
	await light_tween.finished
	Global.player.light.enabled = false
