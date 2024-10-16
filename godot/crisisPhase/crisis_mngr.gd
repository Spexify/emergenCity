extends Control
class_name EMC_CrisisMngr

## Improvement idea: Move curr EMC_CrisisScenario reference to here from OverworldStateMngr

var _day_mngr :  EMC_DayMngr
var _inventory : EMC_Inventory
var _gui_mngr : EMC_GUIMngr
var _max_day : int
var _max_crisis_overlap : int = 2

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _possible_water_crisis : EMC_OverworldStatesMngr.WaterState = EMC_OverworldStatesMngr.WaterState.CLEAN
const WATER_LOWER_BOUND : int = 1
const WATER_UPPER_BOUND : int = 3
var _water_crisis_probability_countdown : int 
var _water_crisis_length_countdown : int = 2

var _possible_electricity_crisis : EMC_OverworldStatesMngr.ElectricityState = EMC_OverworldStatesMngr.ElectricityState.UNLIMITED
const ELECTRICITY_LOWER_BOUND : int = 1
const ELECTRICITY_UPPER_BOUND : int = 3
var _electricity_crisis_probability_countdown : int 
var _electricity_crisis_length_countdown : int = 2

var _possible_isolation_crisis : EMC_OverworldStatesMngr.IsolationState = EMC_OverworldStatesMngr.IsolationState.NONE
const ISOLATION_LOWER_BOUND : int = 1
const ISOLATION_UPPER_BOUND : int = 5
var _isolation_crisis_probability_countdown : int
var _isolation_crisis_length_countdown : int = 1

var _possible_food_contamination_crisis : EMC_OverworldStatesMngr.FoodContaminationState = EMC_OverworldStatesMngr.FoodContaminationState.NONE
const FOOD_CONTAMINATION_LOWER_BOUND : int = 1
const FOOD_CONTAMINATION_UPPER_BOUND : int = 5
var _food_contamination_crisis_probability_countdown : int
var _food_contamination_crisis_length_countdown : int = 1


func setup(p_backpack : EMC_Inventory, p_gui_mngr: EMC_GUIMngr) -> void: 
	_rng.randomize()
	_inventory = p_backpack
	_gui_mngr = p_gui_mngr
	
	_possible_water_crisis = OverworldStatesMngr.get_water_crisis_status()
	_possible_electricity_crisis = OverworldStatesMngr.get_electricity_crisis_status()
	_possible_isolation_crisis = OverworldStatesMngr.get_isolation_crisis_status()
	_possible_food_contamination_crisis = OverworldStatesMngr.get_food_contamination_crisis_status()

	_max_day = OverworldStatesMngr.get_crisis_length()
	_max_crisis_overlap = OverworldStatesMngr.get_number_crisis_overlap()
	
	_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	if !Global._tutorial_done:
		_electricity_crisis_probability_countdown = 0
	else:
		_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	_food_contamination_crisis_probability_countdown = _rng.randi_range(FOOD_CONTAMINATION_LOWER_BOUND, FOOD_CONTAMINATION_UPPER_BOUND)
	
############################# GETTERS AND SETTERS ##################################################

func get_max_day() -> int:
	return _max_day


func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day


########################################## PUBLIC METHODS ##########################################
func _refresh() -> int:
	var cnt : int = 0
	#check if each crisis is active and reduce their length if so
	if OverworldStatesMngr.get_water_state() != EMC_OverworldStatesMngr.WaterState.CLEAN:
		cnt+= 1
		_water_crisis_length_countdown -= 1
	if OverworldStatesMngr.get_electricity_state() != EMC_OverworldStatesMngr.ElectricityState.UNLIMITED:
		cnt+= 1
		_electricity_crisis_length_countdown -= 1
	if OverworldStatesMngr.get_isolation_state() != EMC_OverworldStatesMngr.IsolationState.NONE:
		cnt+= 1
		_isolation_crisis_length_countdown -= 1
	if OverworldStatesMngr.get_food_contamination_state() != EMC_OverworldStatesMngr.FoodContaminationState.NONE:
		cnt+= 1
		_food_contamination_crisis_length_countdown -= 1
	
	# Inactivate crisis after their length has expired
	if _water_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_water_state(OverworldStatesMngr.WaterState.CLEAN)  ## or 1 depending on crisis
		_water_crisis_length_countdown = 2
		_water_crisis_probability_countdown = _rng.randi_range(WATER_LOWER_BOUND, WATER_UPPER_BOUND)
	if _electricity_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_electricity_state(OverworldStatesMngr.ElectricityState.UNLIMITED) 
		_electricity_crisis_length_countdown = 2
		_electricity_crisis_probability_countdown = _rng.randi_range(ELECTRICITY_LOWER_BOUND, ELECTRICITY_UPPER_BOUND)
	if _isolation_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.IsolationState.NONE)
		_isolation_crisis_length_countdown = 2
		_isolation_crisis_probability_countdown = _rng.randi_range(ISOLATION_LOWER_BOUND, ISOLATION_UPPER_BOUND)
	if _food_contamination_crisis_length_countdown <= 0:
		OverworldStatesMngr.set_food_contamination_state(OverworldStatesMngr.FoodContaminationState.NONE) 
		_food_contamination_crisis_length_countdown = 2
		_food_contamination_crisis_probability_countdown = _rng.randi_range(FOOD_CONTAMINATION_LOWER_BOUND, FOOD_CONTAMINATION_UPPER_BOUND)
	
	#lower countdown of allowed_crises
	if _possible_water_crisis != OverworldStatesMngr.WaterState.CLEAN: 
		_water_crisis_probability_countdown -= 1
	if _possible_electricity_crisis != OverworldStatesMngr.ElectricityState.UNLIMITED:
		_electricity_crisis_probability_countdown -= 1
	if _possible_isolation_crisis != OverworldStatesMngr.IsolationState.NONE:
		_isolation_crisis_probability_countdown -= 1
	if _possible_food_contamination_crisis != OverworldStatesMngr.FoodContaminationState.NONE:
		_food_contamination_crisis_probability_countdown -= 1
	
	return cnt


## Reduce countdowns and check the new states
## Returns the value that showed_new_crises() returns
func check_crisis_status() -> bool:
	var active_crises_cnt := _refresh()
	
	if active_crises_cnt < _max_crisis_overlap:
		if _possible_water_crisis != EMC_OverworldStatesMngr.WaterState.NONE:
			_water_crisis_mngr()
		if _possible_electricity_crisis != EMC_OverworldStatesMngr.ElectricityState.UNLIMITED:
			_electricity_crisis_mngr()
		if _possible_isolation_crisis != EMC_OverworldStatesMngr.IsolationState.NONE:
			_isolation_crisis_mngr()
		if _possible_food_contamination_crisis != EMC_OverworldStatesMngr.FoodContaminationState.NONE:
			_food_contamination_crisis_mngr()
	
	return await _show_new_crises_info()


########################################## PRIVATE METHODS #########################################
func _water_crisis_mngr() -> void:
	if _water_crisis_probability_countdown <= 0:
		if _water_crisis_length_countdown > 0 && \
		OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.CLEAN:
			OverworldStatesMngr.set_water_state(_possible_water_crisis)


func _electricity_crisis_mngr() -> void:
	if _electricity_crisis_probability_countdown <= 0:
		if _electricity_crisis_length_countdown > 0 && \
		OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.UNLIMITED:
			OverworldStatesMngr.set_electricity_state(_possible_electricity_crisis)


func _isolation_crisis_mngr() -> void:
	if _isolation_crisis_probability_countdown <= 0:
		if _isolation_crisis_length_countdown > 0 && \
		OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.IsolationState.NONE:
			OverworldStatesMngr.set_isolation_state(_possible_isolation_crisis)


func _food_contamination_crisis_mngr() -> void:
	if _food_contamination_crisis_probability_countdown <= 0:
		if _food_contamination_crisis_length_countdown > 0:
			_inventory.spoil_all_items()
			if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.FoodContaminationState.NONE:
				OverworldStatesMngr.set_food_contamination_state(_possible_food_contamination_crisis)


## If a new crises was started this period, then show an according information
func _show_new_crises_info() -> bool:
	var showed_new_crises: bool = false
	var active_crises_descr := OverworldStatesMngr.get_active_crises_descr()
	if active_crises_descr != "":
		var callback : Signal = _gui_mngr.queue_gui("TooltipGUI", [active_crises_descr])
		SoundMngr.vibrate(250, 2)
		if not callback.is_null():
			await callback
		showed_new_crises = true
	OverworldStatesMngr.clear_active_crises_descr()
	
	return showed_new_crises
