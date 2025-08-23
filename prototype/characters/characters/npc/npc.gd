# npc.gd
class_name NPC extends Character

@onready var shadow: Sprite2D = $Shadow
@onready var collision: CollisionShape2D = $Collision
@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var movement_manager: MovementManager = $MovementManager
@onready var stats_manager: StatsManager = $StatsManager
@onready var navigation_manager: NavigationManager = $NavigationManager
@onready var animation_manager: AnimationManager = $AnimationManager
@onready var interact_area: Area2D = $InteractArea
@onready var weapon_collision: CollisionShape2D = $WeaponManager/Weapon/WeaponCollision

var player_in_range: bool = false

func _ready() -> void:
	Global.time_is_dawn.connect(_at_dawn_hour)
	Global.time_is_dusk.connect(_at_dusk_hour)
	SignalBus.dead.connect(_on_death)
	dialogue_manager.npc = self
	weapon_collision.disabled = true
	name = resource.name

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("interact") and self is not Enemy:
			if player_in_range and not Dialogue.dialogue_ui.dialogue.visible:
				dialogue_manager.dialogue_start()

func _physics_process(delta: float) -> void:
	if not navigation_manager.is_navigation_finished():
		_movement_check(delta)
	else:
		movement_manager.moving = false
		movement_manager.velocity = Vector2.ZERO

func _movement_check(delta: float) -> void:
	movement_manager.speed = movement_manager.walk_speed
	if navigation_manager.avoidance_enabled:
		movement_manager.char_move(delta, velocity)
	else:
		movement_manager.char_move(delta, navigation_manager.direction)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if self is not Enemy:
		if body.is_in_group("Player"):
			player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _at_dawn_hour() -> void:
	shadow.visible = true
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.WHITE, 60.0)
	await shadow_tween.finished

func _at_dusk_hour() -> void:
	var shadow_tween: Tween = create_tween()
	shadow_tween.tween_property(shadow, "modulate", Color.TRANSPARENT, 60.0)
	await shadow_tween.finished
	shadow.visible = false

func _on_death(character: Character) -> void:
	if character == self:
		z_index = -1
		collision.disabled = true
		interact_area.monitoring = false
		for key in Stats.kill_stats.keys():
			if key == character.resource.id:
				Stats.kill_stats[character.resource.id] += 1
			else:
				Stats.kill_stats[character.resource.id] = 1
			Stats.kills_updated.emit()
