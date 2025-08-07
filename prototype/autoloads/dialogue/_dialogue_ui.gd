# _dialogue_ui.gd
extends Control

@onready var dialogue: PanelContainer = $Dialogue
@onready var name_label: Label = $Dialogue/MarginContainer/VBoxContainer/NameLabel
@onready var dialogue_label: Label = $Dialogue/MarginContainer/VBoxContainer/DialogueLabel
@onready var dialogue_options: HBoxContainer = $Dialogue/MarginContainer/VBoxContainer/DialogueOptions

func _ready() -> void:
	dialogue_ui_hide()

func _unhandled_input(event: InputEvent) -> void:
	if dialogue.visible:
		if event is InputEventKey and event.pressed:
			for i in range(9):
				if dialogue_options.get_children().size() >= i + 1 and Input.is_action_just_pressed(str(i + 1)):
					dialogue_options.get_child(i).pressed.emit()
					break
		if Input.is_action_just_pressed("ui_cancel"):
			dialogue_ui_hide()

func dialogue_ui_show(npc: NPC, text: String, options: Dictionary) -> void:
	Global.player.velocity = Vector2.ZERO
	dialogue.visible = true
	text = text.replace("#PLAYER#", Global.player.resource.name)
	text = text.replace("#NPC#", npc.resource.name)
	name_label.text = npc.resource.name
	dialogue_label.text = text
	for child in dialogue_options.get_children():
		dialogue_options.remove_child(child)
	for option in options.keys():
		var button: Button = Button.new()
		button.pressed.connect(_on_option_selected.bind(npc, option))
		dialogue_options.add_child(button)
		button.text = str("(", str(button.get_index() + 1), ") ", option)

func dialogue_ui_hide() -> void:
	dialogue.visible = false

func _on_option_selected(npc: NPC, option: String) -> void:
	npc.dialogue_manager.dialogue_choice(option)
