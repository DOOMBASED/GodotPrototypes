# _viewport.gd
extends Node

@onready var subpixel_viewport_container: SubViewportContainer = $SubpixelViewportContainer
@onready var subpixel_viewport: SubViewport = $SubpixelViewportContainer/SubpixelViewport
@export var scene_to_load: PackedScene

func _ready() -> void:
	Global.set_viewport(subpixel_viewport_container)
	subpixel_viewport.size = subpixel_viewport_container.size / 2
	var scene_instance: Node2D = scene_to_load.instantiate()
	subpixel_viewport.add_child(scene_instance)
