# _dialogue_ui.gd
extends Control

@onready var dialogue: PanelContainer = $Dialogue
@onready var dialogue_ui_history: PanelContainer = $DialogueUIHistory
@onready var name_label: Label = $Dialogue/MarginContainer/VBoxContainer/NameLabel
@onready var dialogue_label: Label = $Dialogue/MarginContainer/VBoxContainer/DialogueLabel
@onready var dialogue_options: VBoxContainer = $Dialogue/MarginContainer/VBoxContainer/MarginContainer/DialogueOptions
@onready var dialogue_labels: VBoxContainer = $DialogueUIHistory/MarginContainer/ScrollContainer/MarginContainer/DialogueLabels
var default_button_size := Vector2(488.0, 18.0)
var default_label_size := Vector2(486.0, 16.0)
var dialogue_typing_duration: float = 0.025
var dialogue_timeout: bool = false
var dialogue_typing: bool = false

func _ready() -> void:
	dialogue_ui_hide()
	dialogue_ui_history.hide()

func _unhandled_input(event: InputEvent) -> void:
	if dialogue.visible:
		if event is InputEventKey and event.pressed:
			_dialogue_check_input()
		if Input.is_action_just_pressed("ui_cancel"):
			if dialogue_label.visible_ratio == 1.0:
				dialogue_ui_hide()
	else:
		if Input.is_action_just_pressed("show_history"):
			dialogue_ui_history.visible = not dialogue_ui_history.visible

func dialogue_ui_show(npc: NPC, text: String, options: Dictionary) -> void:
	_dialogue_init(npc, text)
	var history_text: String = str(name_label.text, ": ", dialogue_label.text)
	_add_history_label(npc ,history_text)
	_dialogue_set_options(npc, options)
	var dialogue_label_characters: float = float(dialogue_label.get_total_character_count())
	var visible_characters_duration: float = dialogue_label_characters * dialogue_typing_duration
	_dialogue_type(dialogue_label_characters, visible_characters_duration)
	await get_tree().create_timer(visible_characters_duration + 0.5).timeout
	dialogue_typing = false
	if options.keys().size() == 0 and not dialogue_typing:
		_dialogue_timeout()

func dialogue_ui_hide() -> void:
	name_label.text = "NAME"
	dialogue_label.text = "DIALOGUE"
	dialogue.hide()

func _dialogue_init(npc: NPC, text: String) -> void:
	dialogue_ui_history.hide()
	dialogue.show()
	text = text.replace("#PLAYER#", Global.player.resource.name)
	text = text.replace("#NPC#", npc.resource.name)
	name_label.text = npc.resource.name
	name_label.add_theme_color_override("font_color", npc.resource.color_hex)
	dialogue_label.text = text
	dialogue_label.visible_characters = 0

func _dialogue_set_options(npc: NPC, options: Dictionary) -> void:
	for child: Button in dialogue_options.get_children():
		dialogue_options.remove_child(child)
	if options.keys().size() > 0:
		for option: String in options.keys():
			_add_option_button(npc, options, option)
		dialogue_options.show()
	if options.keys().size() == 0:
		dialogue_options.hide()

func _dialogue_check_input() -> void:
	for i: int in range(9):
		if not dialogue_typing:
			if dialogue_options.get_children().size() >= i + 1 and Input.is_action_just_pressed(str(i + 1)):
				dialogue_options.get_child(i).pressed.emit()
				break

func _dialogue_type(char_count: float, typing_duration: float) -> void:
	var visible_characters_tween: Tween = create_tween()
	visible_characters_tween.tween_property(dialogue_label, "visible_characters", char_count, typing_duration)
	dialogue_typing = true

func _dialogue_timeout() -> void:
		dialogue_timeout = true
		await get_tree().create_timer(3.0).timeout
		dialogue_ui_hide()
		dialogue_timeout = false

func _add_history_label(character: Character, history_text: String):
	var history_label := RichTextLabel.new()
	var formatted_text: String = history_text.replace(str(character.resource.name), str("[color=", str(character.resource.color_hex), "]", str(character.resource.name), "[/color]"))
	for label: RichTextLabel in dialogue_labels.get_children():
		if label.text == formatted_text:
			return
	history_label.scroll_active = false
	history_label.bbcode_enabled = true
	history_label.fit_content = true
	history_label.custom_minimum_size = default_label_size
	history_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	history_label.text = formatted_text
	history_label.name = str("Dialogue #", str(dialogue_labels.get_child_count() + 1).pad_zeros(3))
	dialogue_labels.add_child(history_label)

func _add_option_button(npc: NPC, options:Dictionary, option: String) -> void:
	var button := Button.new()
	button.pressed.connect(_on_option_selected.bind(npc, options, option))
	button.custom_minimum_size = default_button_size
	button.autowrap_mode = TextServer.AUTOWRAP_WORD
	dialogue_options.add_child(button)
	button.text = str("(", str(button.get_index() + 1), ") ", option)
	button.name = str("Option #", str(button.get_index() + 1).pad_zeros(2))

func _on_option_selected(character: Character, options: Dictionary, option: String) -> void:
	var history_text: String = str(Global.player.resource.name, ": ", option)
	_add_history_label(Global.player, history_text)
	character.dialogue_manager.dialogue_choice(option)
	options.erase(option)
