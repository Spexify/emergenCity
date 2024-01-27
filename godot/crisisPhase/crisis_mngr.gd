extends Node
class_name EMC_CrisisMngr

var _overworld_states_mngr : EMC_OverworldStatesMngr
var _day_mngr :  EMC_DayMngr

var _max_day : int
var DAY_PERIODS : int = 3
var _crisis_period_counter : int

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

const WATER_LOWER_BOUND : int = 1
const WATER_UPPER_BOUND : int = 4 
var _water_crisis_probability_countdown : int = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
var _water_crisis_length_countdown : int = 3

const ELECTRICITY_LOWER_BOUND : int = 1
const ELECTRICITY_UPPER_BOUND : int = 3 
var _electricity_crisis_probability_countdown : int = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
var _electricity_crisis_length_countdown : int = 3

const ISOLATION_LOWER_BOUND : int = 2
const ISOLATION_UPPER_BOUND : int = 4 
var _isolation_crisis_probability_countdown : int = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
var _isolation_crisis_length_countdown : int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(_p_overworld_states_mngr : EMC_OverworldStatesMngr,
			_p_max_day : int = 3, _p_day_periods : int= 3) -> void:
	_overworld_states_mngr = _p_overworld_states_mngr
	_max_day = _p_max_day
	DAY_PERIODS = _p_day_periods
	_crisis_period_counter = _p_max_day * _p_day_periods
	
# func setup(_p_overworld_states_mngr : EMC_OverworldStatesMngr,
#			_p_day_mngr :  EMC_DayMngr) -> void:
#	_overworld_states_mngr = _p_overworld_states_mngr
#	_day_mngr = _p_day_mngr
		
## start counting time with day_mngr
func check_crisis_status() -> void:
	if _crisis_period_counter != 0:
		
		## check all the counters for the house and the availability 
		## restrict number of catastrophies at the same  time to 2
		## manage catastrophies through overwolrd manager
		
		
		
		
		
		_crisis_period_counter -= 1
	
############################# GETTERS AND SETTERS ##################################################	
	
func get_day_periods() -> int :
	return DAY_PERIODS

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day
	
## 3 types of crisis : water, electricity or places are restricted
## crisis types can overlap
## overworld info from overwolrdstatesmngr and setters
## initialised in crisis phase in the beginning
## manages time using the daymngr
