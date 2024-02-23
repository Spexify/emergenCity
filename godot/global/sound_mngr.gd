extends Node

@onready var button_sfx := $ButtonSFX

var _buttons : Array

func _ready() -> void:
	_buttons = get_tree().get_nodes_in_group("Button")
	for inst : Node in _buttons:
		inst.connect("pressed", on_button_pressed)
		
	Global.scene_changed.connect(reload_groups)

func reload_groups() -> void:
	for inst : Node in _buttons:
		inst.disconnect("pressed", on_button_pressed)

	_buttons = get_tree().get_nodes_in_group("Button")
	for inst : Node in _buttons:
		inst.connect("pressed", on_button_pressed)

func on_button_pressed() -> void:
	button_sfx.play()
