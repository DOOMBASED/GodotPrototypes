# harvestable.gd
class_name Harvestable extends StaticBody2D

@export var resource: ItemMaterial
@export var resource_min_amount: int
@export var resource_max_amount: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

var resource_remaining: int

var init_position: Vector2
var launch_velocity: Vector2
var launch_direction: Vector2
var launch_speed: float = 150
var launch_duration: float = 0.15
var launch_elapsed: float = 0.0
var launching: bool = false

var item_scene: PackedScene = preload("res://items/item/item.tscn")
var smoke_scene: PackedScene = preload("res://effects/smoke.tscn")
var item_spawn_point: Node
var item_instance: Node
var smoke_instance: Node
var tween: Tween

signal harvested

func _ready() -> void:
	resource_remaining = randi_range(resource_min_amount, resource_max_amount)
	await Global.worldspace_set
	item_spawn_point = Global.worldspace.items
	init_position = global_position

func _process(delta: float) -> void:
	_launch_check(delta)
	if resource_remaining <= 0:
		smoke_instance = smoke_scene.instantiate()
		item_spawn_point.add_child(smoke_instance)
		smoke_instance.position = position
		tween = create_tween()
		smoke_instance.emitting = true
		tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
		if scale.x < 0.96:
			smoke_instance.emitting = false
			smoke_instance.queue_free.call_deferred()
		harvested.emit(init_position)
		if not launching:
			queue_free.call_deferred()

func material_harvest() -> void:
	if resource_remaining > 1:
		animation_player.play("hit")
	_material_spawn()
	resource_remaining -= 1
	if Global.player.weapon_manager.equipped_item.type == "Tool - Mining":
		Stats.stats["mining_exp"] += Stats.base_exp_rate * resource.material_exp_multiplier
	if Global.player.weapon_manager.equipped_item.type == "Tool - Woodcutting":
		Stats.stats["woodcutting_exp"] += Stats.base_exp_rate * resource.material_exp_multiplier

func _material_spawn() -> void:
	item_instance = item_scene.instantiate()
	item_instance.resource = resource
	item_instance.position = position
	item_spawn_point.call_deferred("add_child", item_instance)
	Inventory.item_dropped.emit(item_instance)
	launch_direction = Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).normalized()
	_launch(launch_direction * launch_speed, launch_duration)

func _launch_check(delta: float) -> void:
	if launching:
		item_instance.collision.disabled = true
		item_instance.position += launch_velocity * delta
		launch_elapsed += delta
		if launch_elapsed >= launch_duration:
			item_instance.collision.disabled = false
			launching = false

func _launch(velocity: Vector2, duration: float) -> void:
	launch_velocity = velocity
	launch_duration = duration
	launch_elapsed = 0.0
	launching = true

func _on_modulate_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(sprite, "modulate:a", 0.3, 0.2)

func _on_modulate_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(sprite, "modulate:a", 1.0, 0.2)
