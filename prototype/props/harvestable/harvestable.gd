# harvestable.gd
class_name Harvestable extends StaticBody2D

@export var resource: ItemResource
@export var resource_min_amount: int
@export var resource_max_amount: int
@onready var shadow: Sprite2D = $Shadow
@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer


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
	Global.time_is_dawn.connect(_at_dawn_hour)
	Global.time_is_dusk.connect(_at_dusk_hour)
	resource_remaining = randi_range(resource_min_amount, resource_max_amount)
	if Global.worldspace == null:
		await Global.worldspace_set
	item_spawn_point = Global.worldspace.items
	init_position = global_position

func _process(delta: float) -> void:
	_launch_check(delta)
	if resource_remaining <= 0:
		if resource is not ItemCrop:
			smoke_instance = smoke_scene.instantiate()
			item_spawn_point.add_child(smoke_instance)
			smoke_instance.position = position
			tween = create_tween()
			smoke_instance.emitting = true
			tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
			if scale.x < 0.96:
				smoke_instance.emitting = false
		harvested.emit(init_position)
		if not launching:
			queue_free.call_deferred()

func material_harvest() -> void:
	if resource_remaining > 1 and animation_player.has_animation("hit"):
		animation_player.play("hit")
	_material_spawn()
	resource_remaining -= 1
	if Global.player.weapon_manager.equipped_item.type == "Tool - Mining":
		Stats.exp_stats["Mining"] += Stats.base_exp_rate * resource.material_exp_multiplier
		Stats.exp_updated.emit()
	if Global.player.weapon_manager.equipped_item.type == "Tool - Woodcutting":
		Stats.exp_stats["Woodcutting"] += Stats.base_exp_rate * resource.material_exp_multiplier
		Stats.exp_updated.emit()
	if Global.player.weapon_manager.equipped_item.type == "Tool - Farming":
		Stats.exp_stats["Farming"] += Stats.base_exp_rate * resource.crop_exp_multiplier
		Stats.exp_updated.emit()
	for seed_resource: ItemSeed in Global.worldspace.planted_crops:
		if seed_resource.planted == false:
			Global.worldspace.planted_crops.erase(seed_resource)
			break

func _material_spawn() -> void:
	item_instance = item_scene.instantiate()
	item_instance.resource = resource
	item_instance.position = position
	item_spawn_point.add_child.call_deferred(item_instance)
	Inventory.item_dropped.emit(item_instance)
	launch_direction = Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).normalized()
	_launch(launch_direction * launch_speed, launch_duration)

func _launch_check(delta: float) -> void:
	if launching:
		item_instance.sprite.texture = resource.texture
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

func _at_dawn_hour() -> void:
	shadow.visible = true
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.WHITE, 60.0)
	await shadow_tween.finished

func _at_dusk_hour() -> void:
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.TRANSPARENT, 60.0)
	await shadow_tween.finished
	shadow.visible = false

func _on_modulate_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(sprite, "modulate:a", 0.3, 0.2)

func _on_modulate_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(sprite, "modulate:a", 1.0, 0.2)
