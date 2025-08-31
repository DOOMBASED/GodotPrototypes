# item_equipment.gd
class_name ItemEquipment extends ItemResource

@export var valid_projectiles: Array[ItemProjectile]
@export var equip_anim: String
@export var equip_effect: String
@export var equip_effect_magnitude: float
@export var knockback_force: float
@export var exp_multiplier: float
