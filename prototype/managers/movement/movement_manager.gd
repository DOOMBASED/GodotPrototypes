# movement_manager.gd
class_name MovementManager extends Node

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
	last_position = character.global_position

func move(delta: float, direction: Vector2) -> void:
	if character == null:
		return
	if direction:
		if character is Player and Dialogue.dialogue_ui.dialogue.visible:
			return
		if character is NPC and Dialogue.dialogue_ui.talking_to == character.resource.name:
			return
		if speed == walk_speed:
			direction = direction.normalized()
		moving = true
		facing = direction.normalized()
		velocity = direction * speed
		if character.has_node("NavigationManager"):
			character.global_position.lerp(character.navigation_manager.next_position.round(), 0.5 * delta).normalized()
		else:
			character.global_position = character.global_position.round()
	if character.animation_manager.current_state != AnimationManager.AnimationState.ACTION:
		last_position = character.global_position
		character.velocity = velocity
		character.move_and_slide()
	if last_position.distance_to(character.global_position) < 0.6:
		moving = false
		velocity = Vector2.ZERO
