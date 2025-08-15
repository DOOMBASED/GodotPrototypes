# item_resource.gd
class_name ItemResource extends Resource

@export var texture: Texture2D
@export var id: String
@export var name: String
@export var type: String
@export var init: Vector2
@export var count: int = 1
@export var maximum: int = 999
@export var quantity: int
var slot: int = -1
@export var quest: bool = false
const speed: int = 240
