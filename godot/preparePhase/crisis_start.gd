extends Control
class_name EMC_CrisisStart

var _crisis_length : int = 3
const LENGTH_LOWER_BOUND_EASY : int = 2
const LENGTH_UPPER_BOUND_EASY : int = 4 
const LENGTH_LOWER_BOUND_NORMAL : int = 4
const LENGTH_UPPER_BOUND_NORMAL : int = 7 
const LENGTH_LOWER_BOUND_HARD : int = 7
const LENGTH_UPPER_BOUND_HARD : int = 10 

var _number_crisis_overlap : int = 3
const CRISIS_OVERLAP_LOWER_BOUND_EASY : int = 1
const CRISIS_OVERLAP_UPPER_BOUND_EASY : int = 1
const CRISIS_OVERLAP_LOWER_BOUND_NORMAL : int = 1
const CRISIS_OVERLAP_UPPER_BOUND_NORMAL : int = 2 
const CRISIS_OVERLAP_LOWER_BOUND_HARD : int = 2
const CRISIS_OVERLAP_UPPER_BOUND_HARD : int = 3

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _on_continue_pressed() -> void:
	match $VBoxContainer/VBoxContainer/HSlider.value:
		0: 
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_EASY, LENGTH_UPPER_BOUND_EASY)
			_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND_EASY, CRISIS_OVERLAP_UPPER_BOUND_EASY)
		1:
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_NORMAL, LENGTH_UPPER_BOUND_NORMAL)
			_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND_NORMAL, CRISIS_OVERLAP_UPPER_BOUND_NORMAL)
		2:
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_HARD, LENGTH_UPPER_BOUND_HARD)
			_number_crisis_overlap = _rng.randi_range(CRISIS_OVERLAP_LOWER_BOUND_HARD, CRISIS_OVERLAP_UPPER_BOUND_HARD)
		_: push_error("Crisis difficulty level invalid!")	

	Global.set_crisis_difficulty(_crisis_length, _number_crisis_overlap)
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)