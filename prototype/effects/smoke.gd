# smoke.gd
extends CPUParticles2D

func _process(_delta: float) -> void:
	if not emitting:
		queue_free()
