# container.gd
class_name PropContainer extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var container_name: String
@export var inventory: Array = []
@export var inventory_size: int = 16

var player_in_range: bool = false
var container_open: bool = false

func _ready() -> void:
	Inventory.container_updated.connect(_on_container_updated)
	inventory.resize(inventory_size)

func _process(_delta: float) -> void:
	if player_in_range:
		if Global.player.animation_manager.current_state == AnimationManager.AnimationState.IDLE:
			if Input.is_action_just_pressed("interact"):
				if not container_open:
					_open_container()
				else:
					_close_container()

func _slot_new(new_name: String) -> void:
	var new_slot: InventorySlot = Inventory.inventory_ui.slot_scene.instantiate()
	new_slot.drag_start.connect(Inventory.inventory_ui.on_drag_start)
	new_slot.drag_release.connect(Inventory.inventory_ui.on_drag_release)
	Inventory.inventory_ui.container_inventory_grid.add_child(new_slot)
	new_slot.name = new_name
	new_slot.container_slot = true

func _open_container() -> void:
	_set_container_slots()
	container_open = true
	animation_player.play("open")
	await animation_player.animation_finished
	if not Inventory.inventory_ui.inventory.visible:
		Inventory.inventory_ui.inventory_toggle()
	if not Inventory.inventory_ui.container_inventory.visible:
		Inventory.inventory_ui.container_inventory_toggle()
		Inventory.inventory_ui.current_container = self
	_on_container_updated()

func _close_container() -> void:
	container_open = false
	animation_player.play("close")
	if Inventory.inventory_ui.container_inventory.visible:
		Inventory.inventory_ui.container_inventory_toggle()
		Inventory.inventory_ui.current_container = null

func _set_container_slots() -> void:
	var child_count: int = Inventory.inventory_ui.container_inventory_grid.get_child_count()
	if child_count != inventory_size:
		for i: int in Inventory.inventory_ui.container_inventory_grid.get_child_count():
			var child: InventorySlot = Inventory.inventory_ui.container_inventory_grid.get_child(0)
			Inventory.inventory_ui.container_inventory_grid.remove_child(child)
		Inventory.inventory_ui.container_inventory.size = Inventory.inventory_ui.container_inventory.custom_minimum_size
		if inventory_size < 24:
			Inventory.inventory_ui.container_label.text = str("Small ", container_name)
			Inventory.inventory_ui.container_inventory_grid.columns = 4
		else:
			Inventory.inventory_ui.container_label.text = str("Large ", container_name)
			Inventory.inventory_ui.container_inventory_grid.columns = 8
		for i: int in inventory_size:
			_slot_new(str(i))
		var center_x: float = (Global.viewport.size.x - Inventory.inventory_ui.container_inventory.size.x) / 2
		var center_y: float = (Global.viewport.size.y - Inventory.inventory_ui.container_inventory.size.y) / 2
		Inventory.inventory_ui.container_inventory.position = Vector2(center_x, center_y)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if container_open:
			_close_container()

func _on_container_updated() -> void:
	if Inventory.inventory_ui.current_container == self:
		for i: int in range(inventory.size()):
			for slot: InventorySlot in Inventory.inventory_ui.container_inventory_grid.get_children():
				if inventory[i] != null:
					if i == slot.get_index():
						slot.sprite.texture = inventory[i].texture
						slot.resource = inventory[i]
						if slot.resource.quantity > 1:
							slot.quantity_label.text = str(slot.resource.quantity)
						else:
							slot.quantity_label.text = ""
				else:
					if i == slot.get_index():
						slot.sprite.texture = null
						slot.quantity_label.text = ""
						slot.resource = null
