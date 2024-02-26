extends Node

var _buttons : Array
var _guis : Array

@onready var musik := $Musik
@onready var button := $Button
@onready var open_gui := $OpenGUI
@onready var close_gui := $CloseGUI

func _ready() -> void:
	_connect_to_buttons()
	_connect_to_guis()

	Global.scene_changed.connect(reload_groups)

func reload_groups() -> void:
	_connect_to_buttons()
	_connect_to_guis()

func on_button_pressed() -> void:
	button.play()
	
func on_open() -> void:
	open_gui.play()

func on_close() -> void:
	await button.finished
	close_gui.play()
	
func is_musik_playing() -> bool:
	return musik.playing

func play_musik() -> void:
	musik.play()

func play_sound(sound : String, start : float = 0) -> void:
	var sound_player : AudioStreamPlayer
	for player in get_children():
		if sound.to_lower() == player.get_name().to_lower():
			sound_player = player
			break
	if sound_player == null:
		printerr("Error in SoundMngr: Sound with name: \"" + sound + "\" not found.")
		return

	sound_player.seek(start)
	sound_player.play()

#######################################Private Methods##############################################

func _connect_to_buttons() -> void:
	_buttons = get_tree().get_nodes_in_group("Button")
	for inst : Node in _buttons:
		inst.connect("pressed", on_button_pressed, CONNECT_REFERENCE_COUNTED)

func _connect_to_guis() -> void:
	_guis = get_tree().get_nodes_in_group("Gui")
	for inst : Node in _guis:
		inst.connect("opened", on_open, CONNECT_REFERENCE_COUNTED)
		inst.connect("closed", on_close, CONNECT_REFERENCE_COUNTED)
