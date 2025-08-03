# movement.gd

extends Node

var character: Character
var velocity: Vector2
var facing: Vector2
@export var speed: float = 180.0
@export var friction: float = 0.1
var can_move: bool

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func move(direction: Vector2, delta: float) -> void:
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
		velocity.move_toward(Vector2.ZERO, friction * delta)
	character.velocity = velocity
	character.move_and_slide()
