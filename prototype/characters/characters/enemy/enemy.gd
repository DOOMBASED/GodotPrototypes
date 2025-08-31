# enemy.gd
class_name Enemy extends NPC

@onready var test_health_label: Label = $Control/TestHealthLabel

func _ready() -> void:
	super._ready()
	name = str(resource.name, "_" , self.get_instance_id())

func _process(_delta: float) -> void:
	if navigation_manager.current_state == NavigationManager.NavigationState.SEARCH:
		test_health_label.text = str(stats_manager.health).pad_zeros(2).pad_decimals(0)
	if animation_manager.current_state == AnimationManager.AnimationState.DEAD:
		test_health_label.text = "DEAD"

func _on_enemy_interact_area_body_entered(body: Node2D) -> void:
	if self is Enemy:
		if body.is_in_group("Player"):
			player_in_range = true
			if body is Character:
				var direction = global_position.direction_to(body.global_position)
				body.movement_manager.knockback_direction = direction * resource.touch_knockback_force
				body.movement_manager.knockback = true
				body.stats_manager.health_damage(resource.touch_damage)
