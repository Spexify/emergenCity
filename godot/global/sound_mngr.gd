extends Node
class_name EMC_SoundMngr
## MP3-Files don't work on mobile if you just load them, so you have to add another
## AudioStreamPlayer Node!! At least I (MRM) didn't get it to work

const SFX_PATH : String = "res://assets/SFX/"

var _buttons : Array

@onready var musik : AudioStreamPlayer = $Musik
@onready var slow_musik: AudioStreamPlayer = $SlowMusik
@onready var crisis_musik: AudioStreamPlayer = $CrisisMusik
@onready var stinger: AudioStreamPlayer = $Stinger

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

func close_game() -> Signal:
	var currently_playing: AudioStreamPlayer
	currently_playing = get_current_bg_musik()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(currently_playing, "volume_linear", 0, 0.3)#.set_ease(Tween.EASE_OUT)
	return tween.finished

func get_current_bg_musik() -> AudioStreamPlayer:
	return slow_musik if slow_musik.playing else (crisis_musik if crisis_musik.playing else musik)

func play_musik() -> void:
	if musik.playing:
		return
	
	var currently_playing: AudioStreamPlayer
	currently_playing = slow_musik if slow_musik.playing else crisis_musik
	
	await cross_fade_musik(currently_playing, musik)

func play_slow_musik() -> void:
	if slow_musik.playing:
		return
	
	var currently_playing: AudioStreamPlayer
	currently_playing = musik if musik.playing else crisis_musik
	
	await cross_fade_musik(currently_playing, slow_musik)

func cross_fade_musik(from: Node, to: Node) -> Signal:	
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(from, "volume_linear", 0, 3)#.set_ease(Tween.EASE_OUT)
	tween.tween_callback(to.play)
	tween.tween_property(to, "volume_linear", 1, 3).from(0)#.set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(from.stop)
	tween.chain().tween_callback(from.set_volume_linear.bind(1.0))
	return tween.finished
 
func play_stinger() -> void:
	stinger.play()
	#await stinger.finished
	#crisis_musik.play()
	get_current_bg_musik().stop()
	crisis_musik.play()
	
var duration_crisis: int = 0

func next_day() -> void:
	if not crisis_musik.playing:
		return
	duration_crisis += 1
	
	if duration_crisis > 3:
		cross_fade_musik(crisis_musik, musik)
		duration_crisis = 0

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
