extends Node

const SFX_PATH : String = "res://res/SFX/"

var _buttons : Array
var _guis : Array

@onready var musik : AudioStreamPlayer = $Musik
@onready var button : AudioStreamPlayer = $Button
@onready var open_gui : AudioStreamPlayer = $OpenGUI
@onready var close_gui : AudioStreamPlayer = $CloseGUI

func _init() -> void:
	var dir := DirAccess.open(SFX_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".wav"):
				var sound := ResourceLoader.load(SFX_PATH + file_name)
				var player :=  AudioStreamPlayer.new()
				player.stream = sound
				player.name = file_name.get_basename().to_camel_case()
				add_child(player)
				#print("Found Sound: " + file_name.get_basename().to_camel_case())
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")


func _ready() -> void:
	_connect_to_buttons()
	_connect_to_guis()

	Global.scene_changed.connect(reload_groups)

func reload_groups() -> void:
	_connect_to_buttons()
	_connect_to_guis()

func on_button_pressed() -> void:
	button.play()
	await button.finished
	
func on_open() -> void:
	open_gui.play()

func on_close() -> void:
	await button.finished
	close_gui.play()
	
func is_musik_playing() -> bool:
	return musik.playing

func play_musik() -> void:
	musik.play()

func play_sound(sound : String, start : float = 0, pitch : float = 1) -> Signal:
	if sound == "":
		return Signal()
	
	var sound_player : AudioStreamPlayer
	for player in get_children():
		if sound.to_camel_case() == player.get_name().to_camel_case():
			sound_player = player
			break
	if sound_player == null:
		printerr("Error in SoundMngr: Sound with name: \"" + sound + "\" not found.")
		return Signal()

	sound_player.set_pitch_scale(pitch)
	sound_player.play(start)
	return sound_player.finished




func vibrate(time : int = 250) -> void:
	Input.vibrate_handheld(time)

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
