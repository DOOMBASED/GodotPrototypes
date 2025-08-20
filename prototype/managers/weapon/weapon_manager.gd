# weapon_manager.gd
class_name WeaponManager extends Node2D

@onready var character: Character = null
var equipped_item: ItemEquipment = null
@onready var projectile_origin: Marker2D = $ProjectileOrigin
var projectile_direction: Vector2
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()
	Inventory.inventory_ui.menu.item_equipped.connect(_on_equipped)

func action_shoot(projectile_scene: PackedScene) -> void:
	var new_projectile: Node = projectile_scene.instantiate()
	var projectile: ItemProjectile = new_projectile.resource
	projectile.slot = Inventory.item_get_index(projectile)
	if Inventory.item_get_count(projectile) > 0:
		projectile_direction = character.animation_manager.animation_tree["parameters/ActionBow/blend_position"].round()
		if projectile_direction == Vector2(-1.0, 1.0) or projectile_direction == Vector2(1.0, 1.0):
			projectile_direction = Vector2(0.0, 1.0)
		elif projectile_direction == Vector2(-1.0, -1.0) or projectile_direction == Vector2(1.0, -1.0):
			projectile_direction = Vector2(0.0, -1.0)
		elif projectile_direction == Vector2.ZERO:
			return
		new_projectile.global_position = character.weapon_manager.projectile_origin.global_position
		Global.worldspace.add_child(new_projectile)
		Inventory.item_remove(projectile, projectile.slot)
	else:
		Global.set_debug_text(str("No ", projectile.name))

func _knockback(body: Character) -> void:
	var knockback_direction = character.global_position.direction_to(body.global_position)
	body.movement_manager.knockback_direction = knockback_direction * equipped_item.knockback_force
	body.movement_manager.knockback = true

func _on_weapon_body_entered(body: Node2D) -> void:
	if body is Harvestable:
		if body.resource.material_tool_type == character.animation_manager.equip_anim:
			body.material_harvest()
	if body.resource is EnemyResource:
		_knockback(body)
		body.stats_manager.health_damage(equipped_item.equip_effect_magnitude)
		SignalBus.attacked.emit(body)
func _on_equipped(_slot: int) -> void:
	if equipped_item != null:
		sprite.texture = equipped_item.texture
