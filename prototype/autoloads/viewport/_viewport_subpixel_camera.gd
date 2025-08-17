# _viewport_subpixel_camera.gd
class_name SubpixelCamera extends Camera2D

var camera_position: Vector2
var camera_speed: float

func _ready() -> void:
	camera_speed = 4.0

func _physics_process(delta: float) -> void:
	if camera_position.round() != Global.player.global_position.round():
		camera_position = camera_position.lerp(Global.player.global_position, delta * camera_speed)
		var camera_subpixel_offset = camera_position.round() - camera_position
		Global.viewport.material.set_shader_parameter("camera_offset", camera_subpixel_offset)
		global_position = camera_position.round()
