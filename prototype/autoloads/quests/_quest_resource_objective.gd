# _quest_resource_objective.gd
class_name QuestResourceObjective extends Resource

enum TargetTypes {talk_to, collection, eliminate}

@export var id: String
@export_multiline var description: String
@export var target_id: String
@export var target_type: TargetTypes
@export_multiline var objective_dialogue: String = ""
@export var required_count: int = 0
var collected_count: int = 0
@export var required_kills: int = 0
var kill_count: int = 0
var is_completed: bool =  false
