# _quest_ui.gd
extends Control

@onready var quests: PanelContainer = $Quests
@onready var quest_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/QuestList
@onready var title_label: Label = $Quests/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $Quests/MarginContainer/VBoxContainer/DescriptionLabel
@onready var objectives_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/ObjectivesList
@onready var rewards_list: VBoxContainer = $Quests/MarginContainer/VBoxContainer/RewardsList

var current_quest: QuestResource = null

func _ready() -> void:
	_quest_details_clear()
	Inventory.connect("item_added", _on_item_added)
	Quests.quest_updated.connect(_on_quest_updated)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("toggle_quest_ui"):
			_quest_log_toggle()

func quest_selected(quest: QuestResource) -> void:
	if quest:
		current_quest = quest
		Quests.current_quest = quest
		Quests._quest_check_tracker(quest)
		title_label.text = quest.name
		description_label.text = quest.description
		for child in objectives_list.get_children():
			objectives_list.remove_child(child)
		for objective in quest.objectives:
			var label = Label.new()
			for i: int in range(Inventory.inventory.size()):
				if Inventory.inventory[i] != null and Inventory.inventory[i].id == objective.target_id:
					if objective.collected_quantity < objective.required_quantity:
						objective.collected_quantity = Inventory.inventory[i].quantity
					Quests.quest_check_objectives(Inventory.inventory[i].id, "collection", 0)
			if objective.target_type == "collection":
				if objective.collected_quantity > objective.required_quantity:
					objective.collected_quantity = objective.required_quantity
				label.text = str(objective.description, "(", str(objective.collected_quantity), "/", str(objective.required_quantity), ")")
			else:
				label.text = objective.description
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1, 0, 0))
			objectives_list.add_child(label)
		for child in rewards_list.get_children():
			rewards_list.remove_child(child)
		for reward in quest.rewards:
			var label = Label.new()
			label.add_theme_color_override("font_color", Color(0, 0.85, 0))
			label.text = str("Rewards: ", reward.type.name, ": ", str(reward.amount))
			rewards_list.add_child(label)
		if quest.complete_check():
			Quests.quest_list_updated.emit()

func _quest_log_toggle() -> void:
	Quests.quest_ui.quests.visible = !Quests.quest_ui.quests.visible
	_quest_list_update()
	if current_quest:
		quest_selected(current_quest)

func _quest_list_update() -> void:
	for child in quest_list.get_children():
		quest_list.remove_child(child)
	var active_quests = Quests.quest_get_active()
	if active_quests.size() == 0:
		_quest_details_clear()
		Quests.current_quest = null
		Quests._quest_check_tracker(null)
	else:
		for quest in active_quests:
			var button = Button.new()
			button.text = str("Track ", quest.name)
			button.pressed.connect(quest_selected.bind(quest))
			quest_list.add_child(button)
	Quests._quest_check_tracker(current_quest)

func _quest_details_clear() -> void:
	title_label.text = "No Active Quest"
	description_label.text = ""
	for child in objectives_list.get_children():
		objectives_list.remove_child(child)
	for child in rewards_list.get_children():
		rewards_list.remove_child(child)

func _on_quest_updated(id: String) -> void:
	if current_quest and current_quest.id == id:
		quest_selected(current_quest)
	current_quest = null
	Quests.current_quest = null
	_quest_details_clear()
	_quest_list_update()

func _on_item_added(_item: ItemResource, _iterator: int) -> void:
	quest_selected(current_quest)
