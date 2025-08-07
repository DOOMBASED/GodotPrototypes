# _quests.gd
extends Node

@onready var quest_ui: Control = $Interface/QuestUI
@onready var quest_tracker: PanelContainer = $Interface/QuestUI/QuestTracker
@onready var title_label: Label = $Interface/QuestUI/QuestTracker/MarginContainer/VBoxContainer/TitleLabel
@onready var objectives_list: VBoxContainer = $Interface/QuestUI/QuestTracker/MarginContainer/VBoxContainer/ObjectivesList

var quests: Dictionary = {}
var current_quest: QuestResource = null

signal quest_updated(id)
signal quest_list_updated()

func _ready() -> void:
	quest_updated.connect(_on_quest_updated)

func quest_add(quest: QuestResource) -> void:
	quests[quest.id] = quest
	quest_updated.emit(quest.id)
	quest_ui.quest_selected(quest)
	_quest_check_tracker(quest)
	Global.set_debug_text(str(quest.name, " added."))

func quest_get_active() -> Array:
	var active_quests = []
	for quest in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func quest_check_items(item_id: String) -> bool:
	if current_quest != null:
		for objective in current_quest.objectives:
			if objective.target_id == item_id and objective.target_type == "collection" and not objective.is_completed:
				return true
	return false

func quest_check_objectives(target_id: String, target_type: String, quantity: int = 1) -> void:
	if current_quest == null:
		return
	var objective_updated: bool = false
	for objective in current_quest.objectives:
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
	var quest = _quest_get(id)
	if quest:
		var quest_name = current_quest.name
		quest.state = state
		quest_updated.emit(id)
		if state == "completed":
			Global.set_debug_text(str(quest_name, " completed."))
			_quest_remove(id)
			current_quest = null

func _quest_remove(id: String) -> void:
	quests.erase(id)
	quest_list_updated.emit()

func _quest_check_tracker(quest: QuestResource) -> void:
	if quest:
		quest_tracker.visible = true
		objectives_list.visible = true
		title_label.text = quest.name
		for child in objectives_list.get_children():
			objectives_list.remove_child(child)
		for objective in quest.objectives:
			var label: Label = Label.new()
			label.text = objective.description
			if objective.target_type == "collection":
				label.text = str(objective.description, "(", str(objective.collected_quantity), "/", str(objective.required_quantity), ")")
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1, 0, 0))
			objectives_list.add_child(label)
	elif !quest:
		title_label.text = "No Active Quests"
		quest_tracker.visible = false
		objectives_list.visible = false
	else:
		quest_tracker.visible = false

func _quest_check_rewards(quest: QuestResource) -> void:
	for reward in quest.rewards:
		if reward.type != null:
			var init_count = reward.type.count
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
