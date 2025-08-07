# _quest_resource_objective.gd
class_name QuestResourceObjective extends Resource

@export var id: String
@export var description: String
@export var target_id: String
@export var target_type: String
@export var objective_dialogue: String = ""
@export var required_quantity: int = 0
@export var collected_quantity: int = 0
@export var is_completed: bool =  false
