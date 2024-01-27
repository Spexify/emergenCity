extends Node
class_name EMC_CrisisMngr

var _overworld_states_mngr : EMC_OverworldStatesMngr
var _day_mngr :  EMC_DayMngr

var _max_day : int
var DAY_PERIODS : int = 3
var _crisis_period_counter : int

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _water_crisis : bool = false
const WATER_LOWER_BOUND : int = 1
const WATER_UPPER_BOUND : int = 4 
var _water_crisis_probability_countdown : int 
var _water_crisis_length_countdown : int = 3

var _electricity_crisis : bool = false
const ELECTRICITY_LOWER_BOUND : int = 1
const ELECTRICITY_UPPER_BOUND : int = 6
var _electricity_crisis_probability_countdown : int 
var _electricity_crisis_length_countdown : int = 3

var _isolation_crisis : bool = false
const ISOLATION_LOWER_BOUND : int = 2
const ISOLATION_UPPER_BOUND : int = 4 
var _isolation_crisis_probability_countdown : int
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
	
	_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	print(_water_crisis_probability_countdown)
	print(_electricity_crisis_probability_countdown)
	
	
############################# GETTERS AND SETTERS ##################################################	
	
func get_day_periods() -> int :
	return DAY_PERIODS

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day


########################## PUBLIC METHODS #########################################################

## start counting time with day_mngr
func check_crisis_status() -> void:
	if _crisis_period_counter != 0:
		## TODO add isolation restriction
		if _overworld_states_mngr.get_electricity_state() == 1 || _overworld_states_mngr.get_water_state() != 0:
			## TODO: check countdowns and limit catastrophe number at the same time
			_water_crisis_mngr()
			print("water crisis: " + str(_water_crisis_length_countdown))
			_electricity_crisis_mngr()
			print("electricity crisis: " + str(_electricity_crisis_length_countdown))
			_isolation_crisis_mngr()
		_crisis_period_counter -= 1

########################## PRIVATE METHODS #########################################################

func _water_crisis_mngr() -> void:
	if _water_crisis_probability_countdown == 0:
		_water_crisis = true
		if _water_crisis_length_countdown != 0:
			_overworld_states_mngr.set_water_state(0)  ## or 1 depending on crisis
			_water_crisis_length_countdown -= 1
		else:
			_overworld_states_mngr.set_water_state(2)  ## or 1 depending on crisis
			_water_crisis_length_countdown = 3
			_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
			_water_crisis = false
	else:
		_water_crisis_probability_countdown -= 1
		
func _electricity_crisis_mngr() -> void:
	if _electricity_crisis_probability_countdown == 0:
		_electricity_crisis = true
		if _electricity_crisis_length_countdown != 0:
			_overworld_states_mngr.set_electricity_state(0)
			_electricity_crisis_length_countdown -= 1
		else:
			_overworld_states_mngr.set_electricity_state(1) 
			_electricity_crisis_length_countdown = 3
			_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
			_electricity_crisis = false
	else:
		_electricity_crisis_probability_countdown -= 1
		
func _isolation_crisis_mngr() -> void:
	if _isolation_crisis_probability_countdown == 0:
		_isolation_crisis = true
		if _isolation_crisis_length_countdown != 0:
			_overworld_states_mngr.set_isolation_state(0)
			_isolation_crisis_length_countdown -= 1
		else:
			_overworld_states_mngr.set_isolation_state(1) 
			_isolation_crisis_length_countdown = 3
			_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
			_isolation_crisis = false
	else:
		_isolation_crisis_probability_countdown -= 1
