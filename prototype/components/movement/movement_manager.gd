# movement_manager.gd

extends Node

var character: Character
var velocity: Vector2
var facing: Vector2
var last_position: Vector2
@export var walk_speed: float = 64.0
@export var run_speed: float = 96.0
var speed: float
var moving: bool = false

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()
	last_position = character.position

func move(direction: Vector2) -> void:
	if character == null:
		return
	if direction:
		moving = true
		direction = direction.round()
		facing = direction.round()
		character.position = character.position.round()
		velocity = direction * speed
	if last_position.distance_to(character.position) == 0:
		moving = false
	if character.animation_manager.current_state != 3:
		last_position = character.position
		character.velocity = velocity
		character.move_and_slide()
