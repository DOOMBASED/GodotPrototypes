# stats_manager.gd
class_name StatsManager extends Node

var character: Character

@export var health_max: float = 100.0
@export var stamina_max: float = 100.0
@export var magic_max: float = 100.0

var health: float
var stamina: float
var magic: float
var stamina_drain: float = 0.30
var stamina_gain: float = 0.15
var stamina_cooldown: bool = false
var stamina_full: bool = true
var dead: bool = false

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()
	health = health_max
	stamina = stamina_max
	magic = magic_max

func _process(_delta: float) -> void:
	_health_check()
	_stamina_check()
	_magic_check()
	if character is not Player and dead:
		character.navigation_manager.target_position = character.global_position
		character.animation_manager.current_state = AnimationManager.AnimationState.DEAD

func health_damage(damage: float) -> void:
	Global.set_debug_text(str("Applied ", damage, " damage."))
	health -= damage

func _health_check() -> void:
	if not get_tree().paused:
		if health < health_max and not dead:
			if health <= 0:
				health = 0
				dead = true
				Global.set_debug_text("DEAD")

func _stamina_check() -> void:
	if not get_tree().paused:
		if stamina < stamina_max:
			stamina_full = false
		if not stamina_full:
			if stamina_cooldown:
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > stamina_max / 4:
					stamina_cooldown = false
			elif not stamina_cooldown and character.animation_manager.current_state != AnimationManager.AnimationState.RUN:
				stamina += stamina_gain
			if stamina > stamina_max:
				stamina_full = true
				stamina = stamina_max

func _magic_check() -> void:
	if not get_tree().paused:
		if magic < magic_max:
			Global.set_debug_text("MAGIC")
