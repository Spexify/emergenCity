extends Node
class_name EMC_SoundMngr
## MP3-Files don't work on mobile if you just load them, so you have to add another
## AudioStreamPlayer Node!! At least I (MRM) didn't get it to work

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
			if not dir.current_is_dir() and (file_name.ends_with(".wav") or file_name.ends_with(".mp3")):
				var sound := ResourceLoader.load(SFX_PATH + file_name)
				var player :=  AudioStreamPlayer.new()
				player.stream = sound
				player.name = file_name.get_basename().to_pascal_case()
				player.process_mode = PROCESS_MODE_ALWAYS
				add_child(player)
				#print("Found Sound: " + file_name.get_basename().to_camel_case())
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")


func _ready() -> void:
	_connect_to_buttons()
	
	Global.scene_changed.connect(reload_groups)


func reload_groups() -> void:
	_connect_to_buttons()


func on_button_pressed() -> void:
	button.play()


func button_finished() -> Signal:
	return button.finished


func play_open() -> void:
	open_gui.play()


func play_close() -> void:
	close_gui.play()


func is_musik_playing() -> bool:
	return musik.playing


func play_musik() -> void:
	musik.play()


func play_sound(sound : String, start : float = 0, pitch : float = 1) -> AudioStreamPlayer:
	if sound == "":
		return null
	
	var sound_player : Array[AudioStreamPlayer]
	for player in get_children():
		if player.get_name().begins_with(sound.to_pascal_case()):
			sound_player.append(player)
			
	if sound_player == null or sound_player.is_empty():
		printerr("Error in SoundMngr: Sound with name: \"" + sound + "\" not found.")
		return null
	
	var player : AudioStreamPlayer = sound_player.pick_random()
	
	player.set_pitch_scale(pitch)
	player.play(start)
	return player


func vibrate(time : int = 250, p_times: int = 1, p_delay_between_times_in_ms: int = 150) -> void:
	for i in p_times:
		Input.vibrate_handheld(time)
		await get_tree().create_timer(p_delay_between_times_in_ms / 1000.0).timeout

#######################################Private Methods##############################################

func _connect_to_buttons() -> void:
	_buttons = get_tree().get_nodes_in_group("Button")
	for inst : Node in _buttons:
		inst.connect("pressed", on_button_pressed, CONNECT_REFERENCE_COUNTED)
