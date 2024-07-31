extends Node
class_name EMC_OverworldStatesMngr

enum Difficulty{
	TUTORIAL = -1,
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}

enum SemaphoreColors{
	RED = 0,
	YELLOW = 1,
	GREEN = 2,
}

enum MobileNetState{
	ONLINE = SemaphoreColors.GREEN,
	OFFLINE = SemaphoreColors.RED
}

var _mobilenet_state : MobileNetState = MobileNetState.ONLINE

enum ElectricityState{
	NONE = SemaphoreColors.RED,
	UNLIMITED = SemaphoreColors.GREEN
}
var _electricity_state: ElectricityState = ElectricityState.UNLIMITED

enum WaterState{
	NONE = SemaphoreColors.RED,
	DIRTY = SemaphoreColors.YELLOW,
	CLEAN = SemaphoreColors.GREEN
}

var _water_state: WaterState = WaterState.CLEAN

enum IsolationState{
	NONE = SemaphoreColors.GREEN,
	LIMITED_PUBLIC_ACCESS = SemaphoreColors.YELLOW,
	ISOLATION = SemaphoreColors.RED,
}

var _isolation_state: IsolationState = IsolationState.NONE

enum FoodContaminationState{
	NONE = SemaphoreColors.GREEN,
	FOOD_SPOILED = SemaphoreColors.RED
}

var _food_contamination_state: FoodContaminationState = FoodContaminationState.NONE

var _upgrades: Array[EMC_Upgrade]

var _difficulty_crisis : Difficulty
var _run_length : int

var _crisis_description : Dictionary

func _ready() -> void:
	add_to_group("Save", true)

func setup(p_upgrades: Array[EMC_Upgrade]) -> void:
	_upgrades = p_upgrades

func set_crisis_difficulty(p_run_length : int = 3, p_difficulty_crisis : Difficulty = Difficulty.EASY) -> void:
	_difficulty_crisis = p_difficulty_crisis
	_run_length = p_run_length

func get_crisis_length() -> int:
	return _run_length

func get_difficulty() -> Difficulty:
	return _difficulty_crisis

## Returns scenario name
func get_scenario_names() -> Array[String]:
	var result : Array[String]
	result.assign(_crisis_description.keys())
	return result
	
func get_scenario_name() -> String:
	return ""

func get_description_by_name(scenario : String) -> Dictionary:
	if _crisis_description.has(scenario):
		return _crisis_description[scenario]
	else:
		return {"Error" : "No such Scenario"}
		
func get_description_by_index(index : int) -> Dictionary:
	return _crisis_description[_crisis_description.keys()[index]]
	
func get_descriptions() -> Dictionary:
	return _crisis_description
	
func add_scenario_notification(scenario_name : String, notification : String) -> void:
	if not _crisis_description.has(scenario_name):
		_crisis_description[scenario_name] = {"notification": notification}
	else:
		_crisis_description[scenario_name]["notification"]= notification
	
func add_scenario_entry(scenario_name : String, index : String, desc : String, states : Array[String]) -> void:
	if not _crisis_description.has(scenario_name):
		return
	_crisis_description[scenario_name][index] = { "desc": desc, "states": states }
	
func remove_scenario_by_name(scenario_name : String) -> void:
	if _crisis_description.has(scenario_name):
		_crisis_description.erase(scenario_name)
		
func remove_scenario_entry(scenario_name : String, index : String) -> void:
	if _crisis_description.has(scenario_name):
		_crisis_description[scenario_name].erase(index)

## Returns notification for radio
func get_notification() -> Array[String]:
	var result : Array[String]
	result.assign(_crisis_description.values().map(func(dict : Dictionary) -> String: return dict["notification"]))
	return result

func get_electricity_state() -> ElectricityState:
	return _electricity_state

func set_electricity_state(new_electricity_state: ElectricityState) -> void:
	_electricity_state = new_electricity_state

func get_electricity_state_descr() -> String:
	match _electricity_state:
		ElectricityState.NONE: return "Ausgefallen!"
		ElectricityState.UNLIMITED: return "Vorhanden."
	return ""


func get_water_state() -> WaterState:
	return _water_state

func set_water_state(new_water_state: WaterState) -> void:
	_water_state = new_water_state

func get_water_state_descr() -> String:
	match _water_state:
		WaterState.NONE: return "Ausgefallen!"
		WaterState.DIRTY: return "Verdreckt."
		WaterState.CLEAN: return "Vorhanden."
	return ""


func get_isolation_state() -> IsolationState:
	return _isolation_state

func set_isolation_state(new_isolation_state: IsolationState) -> void:
	_isolation_state = new_isolation_state

func get_isolation_state_descr() -> String:
	match _isolation_state:
		IsolationState.NONE: return "Keine."
		IsolationState.LIMITED_PUBLIC_ACCESS: return "Einige Betretsverbote."
		IsolationState.ISOLATION: return "Quarantäne!"
	return ""


func get_food_contamination_state() -> FoodContaminationState:
	return _food_contamination_state

func set_food_contamination_state(new_food_contamination_state: FoodContaminationState) -> void:
	_food_contamination_state = new_food_contamination_state

func get_food_contamination_state_descr() -> String:
	match _food_contamination_state:
		FoodContaminationState.NONE:
			if _electricity_state == ElectricityState.NONE:
				return "Reduz. Essens-Haltbarkeit"
			else: return "Kein Problem."
		FoodContaminationState.FOOD_SPOILED: return "Kontaminiert!"
	return ""
	
func get_mobile_net_state() -> int:
	return _mobilenet_state

func set_mobile_net_state(new_mobilenet_state: int) -> void:
	_mobilenet_state = new_mobilenet_state

func get_mobile_net_state_descr() -> String:
	match _mobilenet_state:
		MobileNetState.ONLINE:
			return "Kein Problem."
		MobileNetState.OFFLINE: return "Keine Verbindung!"
	return ""

var _water : Array[int] = [0, 0, 0]
var _electricity : int = 0
var _food : int = 0
var _isolation : Array[int] = [0, 0, 0]
var _mobile : int = 0

func sub_any_state_by_name(state : String) -> void:
	if "WaterState" in state:
		_water[WaterState.get(state.get_extension())] -= 1
		if _water[0] == 0:
			_water_state = WaterState.DIRTY
			if _water[1] == 0:
				_water_state = WaterState.CLEAN
	elif "ElectricityState" in state:
		_electricity -= 1
		if _electricity == 0:
			_electricity_state = ElectricityState.UNLIMITED
	elif "FoodContaminationState" in state:
		_food -= 1
		if _food == 0:
			_food_contamination_state = FoodContaminationState.NONE
	elif "IsolationState" in state:
		_isolation[IsolationState.get(state.get_extension())] -= 1
		if _isolation[0] == 0:
			_isolation_state = IsolationState.LIMITED_PUBLIC_ACCESS
			if _isolation[1] == 0:
				_isolation_state = IsolationState.NONE
	elif "MobileNetState" in state:
		_mobile -= 1
		if _mobile == 0:
			_mobilenet_state =  MobileNetState.ONLINE

func add_any_state_by_name(state : String) -> void:
	if "WaterState" in state:
		var _state : WaterState = WaterState.get(state.get_extension())
		if _water_state > _state:
			_water_state = _state
			_water[_state] += 1
	elif "ElectricityState" in state:
		var _state : ElectricityState = ElectricityState.get(state.get_extension())
		if _electricity_state > _state:
			_electricity_state = _state
			_electricity += 1
	elif "FoodContaminationState" in state:
		var _state : FoodContaminationState = FoodContaminationState.get(state.get_extension())
		if _food_contamination_state > _state:
			_food_contamination_state = _state
			_food += 1
	elif "IsolationState" in state:
		var _state : IsolationState = IsolationState.get(state.get_extension())
		if _isolation_state > _state:
			_isolation_state = _state
			_isolation[_state] += 1
	elif "MobileNetState" in state:
		var _state : MobileNetState = MobileNetState.get(state.get_extension())
		if _mobilenet_state > _state:
			_mobilenet_state = _state
			_mobile += 1

func set_any_state_by_name(state : String) -> void:
	if "WaterState" in state:
			_water_state = WaterState.get(state.get_extension())
	elif "ElectricityState" in state:
			_electricity_state = ElectricityState.get(state.get_extension())
	elif "FoodContaminationState" in state:
			_food_contamination_state = FoodContaminationState.get(state.get_extension())
	elif "IsolationState" in state:
			_isolation_state = IsolationState.get(state.get_extension())
	elif "MobileNetState" in state:
			_mobilenet_state = MobileNetState.get(state.get_extension())

############################################Furniture###############################################

func get_furniture_state(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state()
	push_error("Upgrade nicht ausgerüstet!")
	return -1

func set_furniture_state(p_upgrade_id: EMC_Upgrade.IDs, new_state: int) -> void:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			upgrade.set_state(new_state)
	push_error("Upgrade nicht ausgerüstet!")

func get_furniture_state_maximum(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state_maximum()
	push_error("Upgrade nicht ausgerüstet!")
	return -1
	
	########################################Save/Load###############################################

## Save function called to get all relevant information. This is used for Saving/loading
func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		#"allowed_water_crisis" : _allowed_water_crisis,
		#"allowed_electricity_crisis" : _allowed_electricity_crisis, 
		#"allowed_isolation_crisis" : _allowed_isolation_crisis,
		#"allowed_food_contamination_crisis" : _allowed_food_contamination_crisis,
		#"scenario_name" : _scenario_name,
		#"crisis_length" : _crisis_length,
		#"number_crisis_overlap" : _number_crisis_overlap,
		#"notification" : _notification,
		"water_state" : _water_state,
		"isolation_state" : _isolation_state,
		"food_contamination_state" : _food_contamination_state,
		"electricity_state" : _electricity_state,
	}
	return data

## Load all relevant information. This is used for Saving/loading
func load_state(data : Dictionary) -> void:
	#var p_water_crisis : WaterState = data.get("allowed_water_crisis")
	#var p_electricity_crisis : ElectricityState = data.get("allowed_electricity_crisis")
	#var p_isolation_crisis : IsolationState = data.get("allowed_isolation_crisis")
	#var p_food_contamination_crisis : FoodContaminationState = data.get("allowed_food_contamination_crisis")
	#var p_scenario_name : String = data.get("scenario_name")
	#var p_crisis_length : int = data.get("crisis_length")
	#var p_number_crisis_overlap : int = data.get("number_crisis_overlap")
	#var p_notification : String = data.get("notification")
	#
	#set_crisis_difficulty(p_scenario_name, p_water_crisis, p_electricity_crisis,
							#p_isolation_crisis, p_food_contamination_crisis,
						#p_crisis_length, p_number_crisis_overlap, p_notification)
						
	var p_water_state : WaterState = data.get("water_state")
	var p_isolation_state : IsolationState = data.get("isolation_state")
	var p_food_contamination_state : FoodContaminationState = data.get("food_contamination_state")
	var p_electricity_state : ElectricityState = data.get("electricity_state")
	
	_set_all_states(p_water_state, p_isolation_state, p_food_contamination_state, p_electricity_state)
	
## This function sets all states without verification, it is needed to load save files
func _set_all_states(p_water_state : WaterState, p_isolation_state : IsolationState,
					p_food_contamination_state : FoodContaminationState, p_electricity_state : ElectricityState) -> void:
	_water_state = p_water_state
	_isolation_state = p_isolation_state
	_food_contamination_state = p_food_contamination_state
	_electricity_state = p_electricity_state
