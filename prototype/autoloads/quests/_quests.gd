# _quests.gd
extends Node

@onready var quest_ui: Control = $Interface/QuestUI
@onready var quest_ui_tracker: PanelContainer = $Interface/QuestUI/QuestUITracker
@onready var title_label: Label = $Interface/QuestUI/QuestUITracker/MarginContainer/VBoxContainer/TitleLabel
@onready var objectives_list: VBoxContainer = $Interface/QuestUI/QuestUITracker/MarginContainer/VBoxContainer/ObjectivesList
var quests: Dictionary = {}
var completed_quests: Array = []
var current_quest: QuestResource = null

signal quest_updated(id)
signal quest_list_updated()

func _ready() -> void:
	quest_updated.connect(_on_quest_updated)
	quest_ui.quests.hide()
	quest_ui_tracker.hide()

func quest_add(quest: QuestResource) -> void:
	quests[quest.id] = quest
	quest_updated.emit(quest.id)
	quest_ui.quest_selected(quest)
	_quest_check_tracker(quest)
	Global.set_debug_text(str(quest.name, " added."))

func quest_get_active() -> Array:
	var active_quests: Array = []
	for quest: QuestResource in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func quest_check_items(item_id: String) -> bool:
	if current_quest != null:
		for objective: QuestResourceObjective in current_quest.objectives:
			if objective.target_id == item_id and objective.target_type == objective.target_types["collection"] and not objective.is_completed:
				return true
	return false

func quest_check_objectives(target_id: String, target_type: int, quantity: int = 1) -> void:
	if current_quest == null:
		return
	var objective_updated: bool = false
	for objective: QuestResourceObjective in current_quest.objectives:
		if objective.target_id == target_id and objective.target_type == target_type and not objective.is_completed:
			current_quest.complete_objective(objective.id, quantity)
			objective_updated = true
			break
	if objective_updated:
		if current_quest.complete_check():
			_quest_check_rewards(current_quest)
		_quest_check_tracker(current_quest)

func _quest_get(id: String):
	return quests.get(id, null)

func _quest_update(id: String, state: String) -> void:
	var quest: QuestResource = _quest_get(id)
	if quest:
		var quest_name: String = current_quest.name
		quest.state = state
		quest_updated.emit(id)
		if state == "completed":
			Global.set_debug_text(str(quest_name, " completed."))
			_quest_remove(id)
			completed_quests.append(quest_name)
			var completed_quest_label := Label.new()
			completed_quest_label.text = str("• ", quest_name)
			completed_quest_label.add_theme_color_override("font_color", Color.DIM_GRAY)
			if completed_quests.size() == 1:
				quest_ui.completed_quest_list.show()
			quest_ui.completed_quest_list.add_child(completed_quest_label)
			current_quest = null

func _quest_remove(id: String) -> void:
	quests.erase(id)
	quest_list_updated.emit()

func _quest_check_tracker(quest: QuestResource) -> void:
	if quest:
		quest_ui_tracker.visible = true
		objectives_list.visible = true
		title_label.text = quest.name
		for child: Label in objectives_list.get_children():
			objectives_list.remove_child(child)
		for objective: QuestResourceObjective in quest.objectives:
			var label := Label.new()
			label.text = objective.description
			if objective.target_type == objective.target_types["collection"]:
				label.text = str(objective.description, "(", str(objective.collected_quantity), "/", str(objective.required_quantity), ")")
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1, 0, 0))
			label.name = str("Objective #", str(objectives_list.get_child_count() + 1).pad_zeros(2))
			objectives_list.add_child(label)
	elif not quest:
		title_label.text = "No Active Quests"
		quest_ui_tracker.visible = false
		objectives_list.visible = false
	else:
		quest_ui_tracker.visible = false

func _quest_check_rewards(quest: QuestResource) -> void:
	for reward: QuestResourceReward in quest.rewards:
		if reward.type != null:
			var init_count: int = reward.type.count
			reward.type.count = reward.amount
			Inventory.item_add(reward.type)
			reward.type.count = init_count
	_quest_check_tracker(quest)
	_quest_update(quest.id, "completed")

func _on_quest_updated(id: String) -> void:
	var quest: QuestResource = _quest_get(id)
	if quest == current_quest:
		_quest_check_tracker(quest)
	current_quest = null
