extends Control
class_name EMC_CrisisMngr

var _day_mngr :  EMC_DayMngr

var _max_day : int
var _crisis_period_counter : int
var _max_crisis_overlap : int = 2

var _message_text : String = "Ooops, manche Systeme für : "

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _water_crisis : bool = false
const WATER_LOWER_BOUND : int = 1
const WATER_UPPER_BOUND : int = 4 
var _water_crisis_probability_countdown : int 
var _water_crisis_length_countdown : int = 2

var _electricity_crisis : bool = false
const ELECTRICITY_LOWER_BOUND : int = 1
const ELECTRICITY_UPPER_BOUND : int = 6
var _electricity_crisis_probability_countdown : int 
var _electricity_crisis_length_countdown : int = 2

var _isolation_crisis : bool = false
const ISOLATION_LOWER_BOUND : int = 2
const ISOLATION_UPPER_BOUND : int = 4 
var _isolation_crisis_probability_countdown : int
var _isolation_crisis_length_countdown : int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup() -> void: #(MRM: Temp. changed P_MAX_DAY to 4 to test shelflife of items)	
	_max_day = Global.get_crisis_length()
	_crisis_period_counter = _max_day * 3
	_max_crisis_overlap = Global.get_number_crisis_overlap()
	
	_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	print("water crisis comes in: " + str(_water_crisis_probability_countdown))
	print("electricity crisis comes in: " + str(_electricity_crisis_probability_countdown))
	print("isolation comes in: " + str(_isolation_crisis_probability_countdown))
	
############################# GETTERS AND SETTERS ##################################################	

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day


########################## PUBLIC METHODS #########################################################
func _refresh() -> int:
	var cnt : int = 0
	if OverworldStatesMngr.get_water_state() != 2:
		cnt+=1
		_water_crisis_length_countdown -= 1 
	if OverworldStatesMngr.get_electricity_state() != 1:
		cnt+=1
		_electricity_crisis_length_countdown -= 1
	if OverworldStatesMngr.get_isolation_state() != 0:
		cnt+=1
		_isolation_crisis_length_countdown -= 1
		
	if _water_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_water_state(2)  ## or 1 depending on crisis
		_water_crisis_length_countdown = 2
		_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	if _electricity_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_electricity_state(1) 
		_electricity_crisis_length_countdown = 2
		_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	if _isolation_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_isolation_state(0) 
		_isolation_crisis_length_countdown = 2
		_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	
	_water_crisis_probability_countdown -= 1
	_electricity_crisis_probability_countdown -= 1
	_isolation_crisis_probability_countdown -= 1	
	
	print("water crisis: " + str(_water_crisis_length_countdown) + "   electricity crisis: " + str(_electricity_crisis_length_countdown)\
	+ "   isolation crisis: " + str(_isolation_crisis_length_countdown))
	
	return cnt

## start counting time with day_mngr
func check_crisis_status() -> void:
	print("water status: " + str(OverworldStatesMngr.get_water_state()))
	print("electricity status: " + str(OverworldStatesMngr.get_electricity_state()))
	print("isolation status: " + str(OverworldStatesMngr.get_isolation_state()))
	if _crisis_period_counter != 0:
		var cnt := _refresh()
	
		if _max_crisis_overlap == 1 && cnt == 0 \
			|| _max_crisis_overlap == 2 && cnt != 2 \
			|| _max_crisis_overlap == 3 && cnt != 3 :
				_water_crisis_mngr()
				_electricity_crisis_mngr()
				_isolation_crisis_mngr()

		_crisis_period_counter -= 1

########################## PRIVATE METHODS #########################################################

func _water_crisis_mngr() -> void:
	if _water_crisis_probability_countdown <= 0:
		if _water_crisis_length_countdown > 0:
			OverworldStatesMngr.set_water_state(0)  ## or 1 depending on crisis
			

		
func _electricity_crisis_mngr() -> void:
	if _electricity_crisis_probability_countdown <= 0:
		if _electricity_crisis_length_countdown > 0:
			OverworldStatesMngr.set_electricity_state(0)
			
		
func _isolation_crisis_mngr() -> void:
	if _isolation_crisis_probability_countdown <= 0:
		if _isolation_crisis_length_countdown > 0:
			OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET)
			
