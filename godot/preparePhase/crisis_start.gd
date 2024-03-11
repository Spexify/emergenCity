extends Control
class_name EMC_CrisisStart

var _crisis_length : int
#Until beginning of length-day (so minus 1 quasi)
const LENGTH_LOWER_BOUND_EASY : int = 4
const LENGTH_UPPER_BOUND_EASY : int = 6
const LENGTH_LOWER_BOUND_NORMAL : int = 7
const LENGTH_UPPER_BOUND_NORMAL : int = 9
const LENGTH_LOWER_BOUND_HARD : int = 10
const LENGTH_UPPER_BOUND_HARD : int = 13

var _number_crisis_overlap : int = 2
const CRISIS_OVERLAP_LOWER_BOUND : int = 1
const CRISIS_OVERLAP_UPPER_BOUND : int = 3


var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _scenario : EMC_CrisisScenario


func _on_continue_pressed() -> void:
	_rng.randomize()
	if $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 0:
		_on_easy_pressed()
	elif $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 1:
		_on_normal_pressed()
	elif $CanvasLayer/VBoxContainer/VBoxContainer/HSlider.value == 2:
		_on_hard_pressed()
	
	var _current_scenario := EMC_CrisisScenario.new() #TODO: Load scenario & its state from savefile..
	
	if Global._tutorial_done: 
		OverworldStatesMngr.set_crisis_difficulty(_current_scenario.crisis_name, _current_scenario.allowed_water_crisis, _current_scenario.allowed_electricity_crisis,
								_current_scenario.allowed_isolation_crisis, _current_scenario.allowed_food_contam_crisis,
								_crisis_length, _number_crisis_overlap, _current_scenario.notification)
	else:
		OverworldStatesMngr.set_crisis_difficulty()
		
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)


func _on_easy_pressed() -> void:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_EASY, LENGTH_UPPER_BOUND_EASY)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)


func _on_normal_pressed() -> void:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_NORMAL, LENGTH_UPPER_BOUND_NORMAL)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)


func _on_hard_pressed() -> void:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_HARD, LENGTH_UPPER_BOUND_HARD)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)


func _on_back_btn_pressed() -> void:
	Global.goto_scene("res://preparePhase/main_menu.tscn")
