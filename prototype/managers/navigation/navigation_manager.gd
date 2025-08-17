# navagation_manager.gd
class_name NavigationManager extends NavigationAgent2D

var character: Character
var direction: Vector2
var next_position: Vector2
var target_set: bool = false

func _ready() -> void:
	navigation_finished.connect(_on_navigation_finished)
	if character == null and get_parent() is Character:
		character = get_parent()
	velocity_computed.connect(Callable(_on_velocity_computed))
	await Global.worldspace_set
	target_position = character.global_position
	target_set = true
	set_movement_target()

func set_movement_target() -> void:
	if not target_set and Dialogue.dialogue_ui.talking_to != character.resource.name:
		target_set = true
		var movement_target: Vector2 = NavigationServer2D.region_get_random_point(Global.worldspace.navigation_region.get_rid(), 1, true)
		set_target_position(movement_target)

func _physics_process(_delta) -> void:
	if NavigationServer2D.map_get_iteration_id(get_navigation_map()) == 0:
		return
	if is_navigation_finished():
		navigation_finished.emit()
		return
	if not Dialogue.dialogue_ui.talking_to != character.resource.name:
		target_position = character.global_position
		return
	next_position = get_next_path_position()
	var new_velocity: Vector2 = character.global_position.direction_to(next_position) * character.movement_manager.speed
	if avoidance_enabled:
		character.set_velocity(new_velocity.normalized())
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity.normalized()
	direction = velocity.normalized()

func _on_navigation_finished() -> void:
	if target_set:
		target_set = false
		await get_tree().create_timer(randf_range(3.0, 6.0)).timeout
		set_movement_target()
