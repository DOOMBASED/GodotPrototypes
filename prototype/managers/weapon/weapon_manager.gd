# weapon_manager.gd
class_name WeaponManager extends Node2D

@onready var character: Character = null
var equipped_item: ItemEquipment = null
@onready var projectile_origin: Marker2D = $ProjectileOrigin
var projectile_direction: Vector2


func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func action_shoot(projectile_scene: PackedScene) -> void:
	var new_projectile: Node = projectile_scene.instantiate()
	var projectile: ItemProjectile = new_projectile.resource
	projectile.slot = Inventory.item_get_index(projectile)
	if Inventory.item_get_count(projectile) > 0:
		projectile_direction = character.movement_manager.facing.normalized()
		if projectile_direction == Vector2(-1.0, 1.0) || projectile_direction == Vector2(1.0, 1.0):
			projectile_direction = Vector2(0.0, 1.0)
		elif projectile_direction == Vector2(-1.0, -1.0) || projectile_direction == Vector2(1.0, -1.0):
			projectile_direction = Vector2(0.0, -1.0)
		elif projectile_direction == Vector2.ZERO:
			return
		new_projectile.global_position = character.weapon_manager.projectile_origin.global_position
		Global.worldspace.add_child(new_projectile)
		Inventory.item_remove(projectile, projectile.slot)
	else:
		Global.set_debug_text(str("No ", projectile.name))

func _on_weapon_body_entered(body: Node2D) -> void:
	if body is Harvestable:
		if body.resource.material_tool_type == character.animation_manager.equip_anim:
			body.material_harvest()
