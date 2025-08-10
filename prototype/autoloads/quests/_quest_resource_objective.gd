# _quest_resource_objective.gd
class_name QuestResourceObjective extends Resource

enum target_types {talk_to, collection}

@export var id: String
@export_multiline var description: String
@export var target_id: String
@export var target_type: target_types
@export_multiline var objective_dialogue: String = ""
@export var required_quantity: int = 0
var collected_quantity: int = 0
var is_completed: bool =  false
