# item.gd
@tool class_name Item extends Area2D

@export var resource: ItemResource
@onready var sprite: Sprite2D = $Sprite
var player_in_range = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		resource.init = position
		if resource != null:
			name = str(resource.name, "_" , self.get_instance_id())
			sprite.texture = resource.texture

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if resource != null:
			sprite.texture = resource.texture
	if not Engine.is_editor_hint():
		_item_check(delta)

func _item_check(delta: float) -> void:
	if player_in_range:
		if Input.is_action_pressed("interact"):
			if not Inventory.inventory_full:
				_item_pickup(delta)
			else:
				_item_stack(delta)

func _item_move(delta: float) -> void:
	position = position.move_toward(Global.player.position.round(), delta * resource.speed)

func _item_pickup(delta: float) -> void:
	if Global.player:
		_item_move(delta)
		if position.round() == Global.player.position.round():
			Global.player.recent_pickup = true
			Inventory.item_add(resource)
			self.call_deferred('queue_free')

func _item_stack(delta: float) -> void:
	var inventory: Array = Inventory.inventory
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i].id == resource.id:
			if inventory[i].quantity != inventory[i].maximum:
				_item_pickup(delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.player.in_item_area = true
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		Global.player.in_item_area = false
