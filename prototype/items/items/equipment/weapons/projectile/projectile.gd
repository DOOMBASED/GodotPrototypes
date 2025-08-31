# projectile.gd
extends Area2D

@export var resource: ItemProjectile

var direction: Vector2
var distance: float
var tween: Tween
var damage_full: float = 0.0

func _ready() -> void:
	rotation = Global.player.weapon_manager.projectile_direction.angle()
	direction = Global.player.animation_manager.animation_tree["parameters/ActionBow/blend_position"].round()
	if direction == Vector2(-1.0, 1.0) or direction == Vector2(1.0, 1.0):
		direction = Vector2(0.0, 1.0)
	elif direction == Vector2(-1.0, -1.0) or direction == Vector2(1.0, -1.0):
		direction = Vector2(0.0, -1.0)
	damage_full = Global.player.weapon_manager.equipped_item.equip_effect_magnitude + resource.projectile_damage
	distance = 0.0

func _physics_process(delta: float) -> void:
	position += direction * resource.projectile_speed * delta
	distance += resource.projectile_speed * delta
	if distance > resource.projectile_range:
		if resource.is_spell:
			tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25)
			tween.tween_callback(queue_free)
		else:
			if resource.recoverable:
				var instance: Item = Inventory.item_scene.instantiate()
				instance.resource = resource
				instance.global_position = global_position
				get_tree().get_first_node_in_group("Worldspace").items.add_child(instance)
				Inventory.item_dropped.emit(instance)
				_set_drop_direction(instance)
				queue_free.call_deferred()
			else:
				Global.set_debug_text("Projectile disappeared into thin air...")
				queue_free.call_deferred()

func _knockback(body: Character) -> void:
	var knockback_direction = global_position.direction_to(body.global_position)
	body.movement_manager.knockback_direction = knockback_direction * resource.knockback_force
	body.movement_manager.knockback = true

func _set_drop_direction(instance: Item) -> void:
	if direction != Vector2.ZERO:
		if direction == Vector2.DOWN:
			instance.sprite.rotation_degrees = 180.0
		if direction == Vector2.LEFT:
			instance.sprite.rotation_degrees = -90.0
		if direction == Vector2.RIGHT:
			instance.sprite.rotation_degrees = 90.0
		if direction == Vector2.UP:
			instance.sprite.rotation_degrees = 0.0

func _on_body_entered(body) -> void:
	if body.resource is EnemyResource:
		if Global.player.weapon_manager.equipped_item.type == "Weapon - Ranged":
			Stats.exp_stats["Ranged"] += Stats.base_exp_rate * damage_full
			Stats.exp_updated.emit()
		_knockback(body)
		body.stats_manager.health_damage(damage_full)
		SignalBus.attacked.emit(body)
	direction = Vector2.ZERO
	queue_free.call_deferred()
