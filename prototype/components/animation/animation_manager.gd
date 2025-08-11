# animation_manager.gd
extends Node

@onready var character: Character = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

enum AnimationState {IDLE, WALK, RUN, ACTION}

var equip_anim: String = ""
var current_state: AnimationState = AnimationState.IDLE

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func _process(_delta: float) -> void:
	if current_state != AnimationState.ACTION:
		if character.has_node("MovementManager"):
			if character.movement_manager.moving:
				current_state = AnimationState.WALK
				animation_tree.set("parameters/Walk/blend_position", character.movement_manager.velocity.normalized())
				if character.has_node("InputManager"):
					if character.input_manager.run:
						current_state = AnimationState.RUN
						animation_tree.set("parameters/Run/blend_position", character.movement_manager.velocity.normalized())
			else:
				current_state = AnimationState.IDLE
				animation_tree.set("parameters/Idle/blend_position", character.movement_manager.facing.normalized())

func action_start() -> void:
	current_state = AnimationState.ACTION
	animation_tree.set(str("parameters/Action", equip_anim,"/blend_position"), character.movement_manager.facing.normalized())

func action_finished() -> void:
	if not Input.is_action_pressed("action"):
		current_state = AnimationState.IDLE
		animation_tree.set("parameters/Idle/blend_position", character.movement_manager.facing.normalized())
