# stats_manager.gd
class_name StatsManager extends Node

var character: Character

var hunger_max: float = 100.0
var thirst_max: float = 100.0
@export var health_max: float = 100.0
@export var stamina_max: float = 100.0
@export var magic_max: float = 100.0

var hunger: float
var thirst: float
var health: float
var stamina: float
var magic: float
var hunger_drain: float = 0.105
var thirst_drain: float = 0.125
var stamina_drain: float = 0.30
var stamina_gain: float = 0.15
var stamina_cooldown: bool = false
var stamina_full: bool = true
var dead: bool = false

func _ready() -> void:
	if character == null and get_parent() is Character:
		character = get_parent()
	hunger = hunger_max
	thirst = thirst_max
	health = health_max
	stamina = stamina_max
	magic = magic_max

func _process(delta: float) -> void:
	_hunger_check(delta)
	_thirst_check(delta)
	_health_check()
	_stamina_check()
	_magic_check()
	if character is not Player and dead:
		character.navigation_manager.target_position = character.global_position
		character.animation_manager.current_state = AnimationManager.AnimationState.DEAD

func health_damage(damage: float) -> void:
	if character is Player:
		Stats.exp_stats["Health"] += Stats.base_exp_rate * damage
		Stats.exp_updated.emit()
	Global.set_debug_text(str("Applied ", damage, " damage."))
	health -= damage

func _hunger_check(delta) -> void:
	if not get_tree().paused:
		if character is Player:
			if hunger > 0:
				hunger -= hunger_drain * delta
				if hunger <= 0:
					hunger = 0

func _thirst_check(delta) -> void:
	if not get_tree().paused:
		if character is Player:
			if thirst > 0:
				thirst -= thirst_drain * delta
				if thirst <= 0:
					thirst = 0

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
