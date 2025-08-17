# character.gd
class_name Character extends CharacterBody2D

@export var resource: CharacterResource

func _ready() -> void:
	name = resource.name
