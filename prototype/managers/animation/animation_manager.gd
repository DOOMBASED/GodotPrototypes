# animation_manager.gd
class_name AnimationManager extends Node

@onready var character: Character = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

var equip_anim: String = ""

enum AnimationState {IDLE, WALK, RUN, ACTION, DAMAGE, DEAD}
var current_state: AnimationState = AnimationState.IDLE

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()

func _process(_delta: float) -> void:
	if character.modulate == Color.TRANSPARENT:
		if character is not Player:
			character.queue_free.call_deferred()
		else:
			Global.global_ui.death_message.visible = true
	if current_state != AnimationState.ACTION:
		if current_state == AnimationState.DEAD:
			animation_tree["parameters/DEAD/blend_position"] = character.movement_manager.facing.normalized()
		if current_state == AnimationState.DAMAGE:
			if character.has_node("NavagationManager"):
				animation_tree["parameters/Damage/blend_position"] = character.navigation_manager.direction
			else:
				animation_tree["parameters/Damage/blend_position"] = character.movement_manager.facing.normalized()
			if character.movement_manager.knockback == false:
				if not character.stats_manager.dead:
					current_state = AnimationState.IDLE
				else:
					current_state = AnimationState.DEAD
		if current_state != AnimationState.DAMAGE and current_state != AnimationState.DEAD:
			if character.movement_manager.moving:
				current_state = AnimationState.WALK
				if character.has_node("NavagationManager"):
					animation_tree["parameters/Walk/blend_position"] = character.navigation_manager.direction
				else:
					animation_tree["parameters/Walk/blend_position"] = character.movement_manager.velocity.normalized()
				if character.has_node("InputManager"):
					if character.input_manager.run and not character.stats_manager.stamina_cooldown:
						current_state = AnimationState.RUN
						animation_tree["parameters/Run/blend_position"] = character.movement_manager.velocity.normalized()
			else:
				current_state = AnimationState.IDLE
				animation_tree["parameters/Idle/blend_position"] = character.movement_manager.facing.normalized()

func action_hoe() -> void:
	Global.worldspace.tilemap.terrain_till(0, 3)

func action_shovel() -> void:
	Global.worldspace.tilemap.terrain_path(0, 1)

func action_sickle() -> void:
	Global.worldspace.tilemap.terrain_harvest()

func action_water() -> void:
	Global.worldspace.tilemap.terrain_water(0, 4)

func action_start() -> void:
	current_state = AnimationState.ACTION
	animation_tree[str("parameters/Action", equip_anim,"/blend_position")] = character.movement_manager.facing.normalized()

func action_finished() -> void:
	if not Input.is_action_pressed("action"):
		current_state = AnimationState.IDLE
		animation_tree["parameters/Idle/blend_position"] = character.movement_manager.facing.normalized()

func _on_death() -> void:
	SignalBus.dead.emit(character)
	await get_tree().create_timer(2.0).timeout
	var alpha_tween: Tween
	alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(character, "modulate", Color.TRANSPARENT, 1.0)
