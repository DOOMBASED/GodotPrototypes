# dialogue_manager.gd
extends Node

var npc: NPC = null

@export var dialogue_file_path: String
@export var quests: Array[QuestResource] = []

var current_state: String = "start"
var current_branch_index: int = 0

func _ready() -> void:
	Dialogue.dialogue_load(dialogue_file_path)

func dialogue_start() -> void:
	var npc_dialogues: Array = Dialogue.dialogue_retrieve(npc.resource.id)
	if npc_dialogues.is_empty():
		return
	current_state = "start"
	_dialogue_show()
	Quests.quest_check_objectives(npc.resource.id, "talk_to")

func dialogue_choice(option: String) -> void:
	var current_dialogue: Dictionary = _dialogue_get_current()
	if not current_dialogue:
		return
	var next_state: String = current_dialogue["options"].get(option, "start")
	_dialogue_set_state(next_state)
	if next_state == "end":
		if _branch_unlock(current_branch_index):
			_branch_advance()
		else:
			Dialogue.dialogue_ui.dialogue_ui_show(npc, "Bye.", {})
	elif next_state == "exit":
		Dialogue.dialogue_ui.dialogue_ui_hide()
	elif next_state == "give_quests":
		_quests_offer(Dialogue.dialogue_retrieve(npc.resource.id)[current_branch_index]["branch_id"])
		_dialogue_show()
	else:
		_dialogue_show()

func _dialogue_show() -> void:
	_branch_check()
	var quest_dialogue: Dictionary = _quest_get_dialogue()
	if quest_dialogue["text"] != "":
		Dialogue.dialogue_ui.dialogue_ui_show(npc, quest_dialogue["text"], quest_dialogue["options"])
	else:
		var dialogue: Dictionary = _dialogue_get_current()
		if dialogue:
			Dialogue.dialogue_ui.dialogue_ui_show(npc, dialogue["text"], dialogue["options"])

func _dialogue_get_current():
	var npc_dialogues: Array = Dialogue.dialogue_retrieve(npc.resource.id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null

func _dialogue_set_branch(branch_index: int) -> void:
	current_branch_index = branch_index
	current_state = "start"

func _dialogue_set_state(state: String) -> void:
	current_state = state

func _branch_check() -> void:
	if _branch_unlock(current_branch_index) and current_branch_index < Dialogue.dialogue_retrieve(npc.resource.id).size() - 1:
		_branch_advance()

func _branch_unlock(branch_index: int) -> bool:
	var branch_id: String = Dialogue.dialogue_retrieve(npc.resource.id)[branch_index]["branch_id"]
	for quest in quests:
		if quest.unlock == branch_id and quest.state != "completed":
			return false
	return true

func _branch_advance() -> void:
	_dialogue_set_branch(current_branch_index + 1)
	_dialogue_set_state("start")
	_dialogue_show()

func _quest_get_dialogue() -> Dictionary:
	var active_quests: Array = Quests.quest_get_active()
	for quest in active_quests:
		for i in range(quest.objectives.size()):
			if quest.objectives[i].id == quest.objectives[i].id:
					if i != 0:
						if not quest.objectives[i - 1].is_completed:
							return {"text": "", "options": {}}
			if quest.objectives[i].target_id == npc.resource.id and quest.objectives[i].target_type == "talk_to" and not quest.objectives[i].is_completed:
				if current_state == "start":
					return {"text": quest.objectives[i].objective_dialogue, "options": {}}
	return {"text": "", "options": {}}

func _quest_offer(id: String) -> void:
	for quest in quests:
		if id == id and quest.state == "not_started":
			quest.state = "in_progress"
			Quests.quest_add(quest)
			return

func _quests_offer(branch_id: String) -> void:
	for quest in quests:
		if quest.unlock == branch_id and quest.state == "not_started":
			_quest_offer(quest.id)
