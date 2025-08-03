# player.gd
class_name Player extends Character

var direction: Vector2

var recent_pickup_limit: float = 42.0
var recent_pickup_time: float = 0.0
var recent_pickup: bool = false
var in_item_area: bool = false

@onready var movement: Node = $Movement

func _ready() -> void:
	Global.set_player(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _physics_process(delta: float) -> void:
	_pickup_check()
	if direction:
		movement.move(direction, delta)

func _pickup_check() -> void:
	if recent_pickup:
		recent_pickup_time += 1.0
		if recent_pickup_time == recent_pickup_limit - 1.0:
			Inventory.inventory_updated.emit()
		if recent_pickup_time >= recent_pickup_limit:
			recent_pickup = false
			recent_pickup_time = 0.0
