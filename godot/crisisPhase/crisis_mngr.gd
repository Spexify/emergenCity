extends Control
class_name EMC_CrisisMngr

var _day_mngr :  EMC_DayMngr

var _max_day : int
var _crisis_period_counter : int
var _max_crisis_overlap : int = 2

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _water_crisis : EMC_OverworldStatesMngr.WaterState = EMC_OverworldStatesMngr.WaterState.CLEAN
const WATER_LOWER_BOUND : int = 1
const WATER_UPPER_BOUND : int = 4 
var _water_crisis_probability_countdown : int 
var _water_crisis_length_countdown : int = 2

var _electricity_crisis : EMC_OverworldStatesMngr.ElectricityState = EMC_OverworldStatesMngr.ElectricityState.UNLIMITED
const ELECTRICITY_LOWER_BOUND : int = 1
const ELECTRICITY_UPPER_BOUND : int = 4
var _electricity_crisis_probability_countdown : int 
var _electricity_crisis_length_countdown : int = 2

var _isolation_crisis : EMC_OverworldStatesMngr.IsolationState = EMC_OverworldStatesMngr.IsolationState.NONE
const ISOLATION_LOWER_BOUND : int = 6
const ISOLATION_UPPER_BOUND : int = 12
var _isolation_crisis_probability_countdown : int
var _isolation_crisis_length_countdown : int = 2

var _food_contamination_crisis : EMC_OverworldStatesMngr.FoodContaminationState = EMC_OverworldStatesMngr.FoodContaminationState.NONE
const FOOD_CONTAMINATION_LOWER_BOUND : int = 6
const FOOD_CONTAMINATION_UPPER_BOUND : int = 12
var _food_contamination_crisis_probability_countdown : int
var _food_contamination_crisis_length_countdown : int = 2

var _inventory : EMC_Inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(p_backpack : EMC_Inventory) -> void: 
				#(MRM: Temp. changed P_MAX_DAY to 4 to test shelflife of items)	
	_inventory = p_backpack
				
	_water_crisis = OverworldStatesMngr.get_water_crisis_status()
	_electricity_crisis = OverworldStatesMngr.get_electricity_crisis_status()
	_isolation_crisis = OverworldStatesMngr.get_isolation_crisis_status()
	_food_contamination_crisis = OverworldStatesMngr.get_food_contamination_crisis_status()

	_max_day = OverworldStatesMngr.get_crisis_length()
	_crisis_period_counter = _max_day * 3
	_max_crisis_overlap = OverworldStatesMngr.get_number_crisis_overlap()
	
	_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	if !Global._tutorial_done:
		_electricity_crisis_probability_countdown = 0
	else:
		_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	_food_contamination_crisis_probability_countdown = _rng.randi_range(FOOD_CONTAMINATION_LOWER_BOUND, FOOD_CONTAMINATION_UPPER_BOUND)
	
	
	#if _water_crisis:
	#	print("water crisis comes in: " + str(_water_crisis_probability_countdown))
	#if _electricity_crisis:
	#	print("electricity crisis comes in: " + str(_electricity_crisis_probability_countdown))
	#if _isolation_crisis:
	#	print("isolation comes in: " + str(_isolation_crisis_probability_countdown))
	#if _food_contamination_crisis:
	#	print("food contamination comes in: " + str(_food_contamination_crisis_probability_countdown))
	
############################# GETTERS AND SETTERS ##################################################	

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day


########################## PUBLIC METHODS #########################################################
func _refresh() -> int:
	var cnt : int = 0
	if OverworldStatesMngr.get_water_state() != EMC_OverworldStatesMngr.WaterState.CLEAN \
		&& _water_crisis != EMC_OverworldStatesMngr.WaterState.NONE:
		cnt+= 1
		_water_crisis_length_countdown -= 3
	if OverworldStatesMngr.get_electricity_state() != EMC_OverworldStatesMngr.ElectricityState.UNLIMITED \
		&& _electricity_crisis != EMC_OverworldStatesMngr.ElectricityState.UNLIMITED:
		cnt+= 1
		_electricity_crisis_length_countdown -= 3
	if OverworldStatesMngr.get_isolation_state() != EMC_OverworldStatesMngr.IsolationState.NONE \
		&& _isolation_crisis != EMC_OverworldStatesMngr.IsolationState.NONE:
		cnt+= 1
		_isolation_crisis_length_countdown -= 3
	if OverworldStatesMngr.get_food_contamination_state() != EMC_OverworldStatesMngr.FoodContaminationState.NONE \
		&& _food_contamination_crisis != EMC_OverworldStatesMngr.FoodContaminationState.NONE:
		cnt+= 1
		_food_contamination_crisis_length_countdown -= 3
		
	if _water_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_water_state(2)  ## or 1 depending on crisis
		_water_crisis_length_countdown = 2
		_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	if _electricity_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_electricity_state(1) 
		_electricity_crisis_length_countdown = 2
		_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	if _isolation_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.IsolationState.NONE) #MRM: Bugfix: Enum instead of Magic number
		_isolation_crisis_length_countdown = 2
		_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	if _food_contamination_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_food_contamination_state(OverworldStatesMngr.FoodContaminationState.NONE)  #MRM: Bugfix: Enum instead of Magic number
		_food_contamination_crisis_length_countdown = 2
		_food_contamination_crisis_probability_countdown = _rng.randi_range(FOOD_CONTAMINATION_LOWER_BOUND, FOOD_CONTAMINATION_UPPER_BOUND)
		
	if _water_crisis: 
		_water_crisis_probability_countdown -= 3
	if _electricity_crisis:
		_electricity_crisis_probability_countdown -= 3
	if _isolation_crisis:
		_isolation_crisis_probability_countdown -= 3	
	if _food_contamination_crisis:
		_food_contamination_crisis_probability_countdown -= 3
	
	#print("water crisis: " + str(_water_crisis_length_countdown) + "   electricity crisis: " + str(_electricity_crisis_length_countdown)\
	#+ "   isolation crisis: " + str(_isolation_crisis_length_countdown)
	#+ "   food_contamination crisis: " + str(_food_contamination_crisis_length_countdown))
	
	return cnt

## start counting time with day_mngr
func check_crisis_status() -> void:
	#print("water status: " + str(OverworldStatesMngr.get_water_state()))
	#print("electricity status: " + str(OverworldStatesMngr.get_electricity_state()))
	#print("isolation status: " + str(OverworldStatesMngr.get_isolation_state()))
	#print("food_contamination status: " + str(OverworldStatesMngr.get_food_contamination_state()))
	
	if _crisis_period_counter != 0:
		var cnt := _refresh()
	
		if _max_crisis_overlap == 1 && cnt == 0 \
			|| _max_crisis_overlap == 2 && cnt != 2 \
			|| _max_crisis_overlap == 3 && cnt != 3 :
				if _water_crisis != EMC_OverworldStatesMngr.WaterState.NONE:
					_water_crisis_mngr()
				if _electricity_crisis != EMC_OverworldStatesMngr.ElectricityState.UNLIMITED:
					_electricity_crisis_mngr()
				if _isolation_crisis != EMC_OverworldStatesMngr.IsolationState.NONE:
					_isolation_crisis_mngr()
				if _food_contamination_crisis != EMC_OverworldStatesMngr.FoodContaminationState.NONE:
					_food_contamination_crisis_mngr()

		_crisis_period_counter -= 3

########################## PRIVATE METHODS #########################################################

func _water_crisis_mngr() -> void:
	if _water_crisis_probability_countdown <= 0:
		if _water_crisis_length_countdown > 0:
			OverworldStatesMngr.set_water_state(_water_crisis)
			

		
func _electricity_crisis_mngr() -> void:
	if _electricity_crisis_probability_countdown <= 0:
		if _electricity_crisis_length_countdown > 0:
			OverworldStatesMngr.set_electricity_state(_electricity_crisis)
			
		
func _isolation_crisis_mngr() -> void:
	if _isolation_crisis_probability_countdown <= 0:
		if _isolation_crisis_length_countdown > 0:
			OverworldStatesMngr.set_isolation_state(_isolation_crisis)
			
func _food_contamination_crisis_mngr() -> void:
	if _food_contamination_crisis_probability_countdown <= 0:
		if _food_contamination_crisis_length_countdown > 0:
			OverworldStatesMngr.set_food_contamination_state(_food_contamination_crisis)
			_inventory.spoil_all_items()
