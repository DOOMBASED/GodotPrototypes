# movement.gd

extends Node

var character: Character
var velocity: Vector2
var facing: Vector2
@export var walk_speed: float = 120.0
@export var run_speed: float = 240.0
var speed: float
var can_move: bool

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func move(direction: Vector2) -> void:
	if character == null:
		return
	if direction:
		can_move = true
		direction = direction.round()
		facing = direction.round()
		character.position = character.position.round()
		velocity = direction * speed
	else:
		can_move = false
		velocity = Vector2.ZERO
	character.velocity = velocity
	character.move_and_slide()
