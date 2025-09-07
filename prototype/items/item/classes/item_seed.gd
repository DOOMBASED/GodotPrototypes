# item_seed.gd
class_name ItemSeed extends ItemResource

@export var harvestable: PackedScene
@export var seed_texture: Texture2D
@export var seed_type: String
@export var seed_atlas: Vector2i
@export var seed_atlas_final: Vector2i
var planted_pos: Vector2i
var planted_hour: float
var times_watered: int
var planted: bool
