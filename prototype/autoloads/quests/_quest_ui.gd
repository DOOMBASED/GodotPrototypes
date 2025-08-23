# _quest_ui.gd
extends Control

@onready var quests: PanelContainer = $Quests
@onready var quest_list_container: MarginContainer = $Quests/MarginContainer/VBoxContainer/QuestListContainer
@onready var quest_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/QuestListContainer/QuestList
@onready var title_label: Label = $Quests/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $Quests/MarginContainer/VBoxContainer/DescriptionLabel
@onready var objectives_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/ObjectivesList
@onready var rewards_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/RewardsList
@onready var completed_quest_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/CompletedQuestList

var current_quest: QuestResource = null

func _ready() -> void:
	_quest_list_clear()
	Inventory.item_added.connect(_on_item_added)
	Quests.quest_updated.connect(_on_quest_updated)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_quests"):
			_quest_log_toggle()

func quest_selected(quest: QuestResource) -> void:
	if quest:
		_quest_set_description(quest)
		_quest_set_objectives(quest)
		_quest_set_rewards(quest)
		if quest.complete_check():
			Quests.quest_list_updated.emit()

func _quest_log_toggle() -> void:
	quests.visible = not quests.visible
	_quest_list_update()
	if current_quest:
		quest_selected(current_quest)

func _quest_set_description(quest: QuestResource) -> void:
	current_quest = quest
	Quests.current_quest = quest
	Quests._quest_check_tracker(quest)
	title_label.text = quest.name
	description_label.text = quest.description
	if description_label.text != "":
		description_label.show()

func _quest_set_objectives(quest: QuestResource) -> void:
	for child: Label in objectives_list.get_children():
		objectives_list.remove_child(child)
	for objective: QuestResourceObjective in quest.objectives:
		var label := Label.new()
		if objective.target_type == QuestResourceObjective.TargetTypes.collection:
			for i: int in range(Inventory.inventory.size()):
				if Inventory.inventory[i] != null and Inventory.inventory[i].id == objective.target_id:
					if objective.collected_count < objective.required_count:
						objective.collected_count = Inventory.inventory[i].quantity
					Quests.quest_check_objectives(Inventory.inventory[i].id, 1, 0)
		if objective.target_type == QuestResourceObjective.TargetTypes.eliminate:
			for key: String in Stats.kill_stats.keys():
				if key != null and key == objective.target_id:
					if objective.kill_count < objective.required_kills:
						objective.kill_count = Stats.kill_stats[key]
					Quests.quest_check_objectives(key, 2, 0)
		if objective.target_type == objective.TargetTypes.collection:
			if objective.collected_count > objective.required_count:
				objective.collected_count = objective.required_count
			label.text = str(objective.description, "(", str(objective.collected_count), "/", str(objective.required_count), ")")
		if objective.target_type == objective.TargetTypes.eliminate:
			if objective.kill_count > objective.required_kills:
				objective.kill_count = objective.required_kills
			label.text = str(objective.description, "(", str(objective.kill_count), "/", str(objective.required_kills), ")")
		else:
			label.text = objective.description
		if objective.is_completed:
			label.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			label.add_theme_color_override("font_color", Color(1, 0, 0))
		label.name = str("Objective #", str(objectives_list.get_child_count() + 1).pad_zeros(2))
		objectives_list.add_child(label)
	if objectives_list.get_child_count() > 0:
		objectives_list.show()

func _quest_set_rewards(quest: QuestResource) -> void:
	for child: Label in rewards_list.get_children():
		rewards_list.remove_child(child)
	for reward: QuestResourceReward in quest.rewards:
		var label := Label.new()
		label.add_theme_color_override("font_color", Color(0, 0.85, 0))
		label.text = str("Rewards: ", reward.type.name, ": ", str(reward.amount))
		label.name = str("Reward #", str(rewards_list.get_child_count() + 1).pad_zeros(2))
		rewards_list.add_child(label)
	if rewards_list.get_child_count() > 0:
		rewards_list.show()
	if quest_list.get_child_count() > 0:
		quest_list_container.show()

func _quest_list_update() -> void:
	for child: Button in quest_list.get_children():
		quest_list.remove_child(child)
	var active_quests: Array = Quests.quest_get_active()
	if active_quests.size() == 0:
		_quest_list_clear()
		Quests.current_quest = null
		Quests._quest_check_tracker(null)
	else:
		for quest: QuestResource in active_quests:
			var button := Button.new()
			button.text = str("Track ", quest.name)
			button.pressed.connect(quest_selected.bind(quest))
			button.name = str("Quest #", str(quest_list.get_child_count() + 1).pad_zeros(2))
			quest_list.add_child(button)
	Quests._quest_check_tracker(current_quest)

func _quest_list_clear() -> void:
	title_label.text = "No Active Quest"
	description_label.text = ""
	description_label.hide()
	for child: Label in objectives_list.get_children():
		objectives_list.remove_child(child)
	objectives_list.hide()
	for child: Label in rewards_list.get_children():
		rewards_list.remove_child(child)
	rewards_list.hide()
	if quest_list.get_child_count() == 0:
		quest_list_container.hide()

func _on_quest_updated(id: String) -> void:
	if current_quest and current_quest.id == id:
		quest_selected(current_quest)
	current_quest = null
	Quests.current_quest = null
	_quest_list_clear()
	_quest_list_update()

func _on_item_added(_item: ItemResource, _iterator: int) -> void:
	quest_selected(current_quest)
