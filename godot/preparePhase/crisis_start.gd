extends Control
class_name EMC_CrisisStart

var _crisis_length : int = 4
const LENGTH_LOWER_BOUND_EASY : int = 2
const LENGTH_UPPER_BOUND_EASY : int = 4 
const LENGTH_LOWER_BOUND_NORMAL : int = 4
const LENGTH_UPPER_BOUND_NORMAL : int = 7 
const LENGTH_LOWER_BOUND_HARD : int = 7
const LENGTH_UPPER_BOUND_HARD : int = 10 

var _number_crisis_overlap : int = 2
const CRISIS_OVERLAP_LOWER_BOUND : int = 1
const CRISIS_OVERLAP_UPPER_BOUND : int = 3


var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _on_continue_pressed() -> void:
	if $VBoxContainer/VBoxContainer/HSlider.value == 0:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_EASY, LENGTH_UPPER_BOUND_EASY)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)
	elif $VBoxContainer/VBoxContainer/HSlider.value == 1:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_NORMAL, LENGTH_UPPER_BOUND_NORMAL)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)
		print(_number_crisis_overlap)
	elif $VBoxContainer/VBoxContainer/HSlider.value == 2:
		_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_HARD, LENGTH_UPPER_BOUND_HARD)
		_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND, CRISIS_OVERLAP_UPPER_BOUND)
	print("difficulty: " + str($VBoxContainer/VBoxContainer/HSlider.value))
	
	
	
	Global.set_crisis_difficulty(_crisis_length, _number_crisis_overlap, true, true, true, false)
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)
