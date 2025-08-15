# weapon_manager.gd
extends Node

@onready var character: Character = null

var equipped_item: ItemEquipment = null

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func _on_weapon_body_entered(body: Node2D) -> void:
	if body is Harvestable:
		if body.resource.material_tool_type == character.animation_manager.equip_anim:
			body.material_harvest()
