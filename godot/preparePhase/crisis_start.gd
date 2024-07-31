extends Control
class_name EMC_CrisisStart

var _crisis_length : int
var _difficulty : OverworldStatesMngr.Difficulty
#Until beginning of length-day (so minus 1 quasi)
const LENGTH_LOWER_BOUND_EASY : int = 4
const LENGTH_UPPER_BOUND_EASY : int = 6
const LENGTH_LOWER_BOUND_NORMAL : int = 7
const LENGTH_UPPER_BOUND_NORMAL : int = 9
const LENGTH_LOWER_BOUND_HARD : int = 10
const LENGTH_UPPER_BOUND_HARD : int = 13


var _rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _on_continue_pressed() -> void:
	_rng.randomize()
	if $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 0:
		_on_easy_pressed()
	elif $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 1:
		_on_normal_pressed()
	elif $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 2:
		_on_hard_pressed()

	
	if Global._tutorial_done: 
		OverworldStatesMngr.set_crisis_difficulty(_crisis_length, _difficulty)
	else:
		OverworldStatesMngr.set_crisis_difficulty(3, OverworldStatesMngr.Difficulty.TUTORIAL)
		
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)


func _on_easy_pressed() -> void:
	_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_EASY, LENGTH_UPPER_BOUND_EASY)
	_difficulty = OverworldStatesMngr.Difficulty.EASY


func _on_normal_pressed() -> void:
	_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_NORMAL, LENGTH_UPPER_BOUND_NORMAL)
	_difficulty = OverworldStatesMngr.Difficulty.MEDIUM


func _on_hard_pressed() -> void:
	_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_HARD, LENGTH_UPPER_BOUND_HARD)
	_difficulty = OverworldStatesMngr.Difficulty.HARD


func _on_back_btn_pressed() -> void:
	Global.goto_scene("res://preparePhase/main_menu.tscn")
