# _quest_resource.gd
class_name QuestResource extends Resource

@export var id: String
@export var unlock: String
@export var name: String
@export var description: String
@export var state: String = "not_started"
@export var objectives: Array[QuestResourceObjective] = []
@export var rewards: Array[QuestResourceReward] = []

func complete_objective(objective_id: String, quantity: int = 1) -> void:
	for i in range(objectives.size()):
		if objectives[i].id == objective_id:
			if i != 0:
				if not objectives[i - 1].is_completed:
					return
			if objectives[i].target_type == "collection":
				objectives[i].collected_quantity += quantity
				if objectives[i].collected_quantity >= objectives[i].required_quantity:
					objectives[i].is_completed = true
			else:
				objectives[i].is_completed = true
				Quests.quest_ui.quest_selected(self)
			break
	if complete_check():
		state = "completed"

func complete_check() -> bool:
	for objective in objectives:
		if not objective.is_completed:
			return false
	return true
