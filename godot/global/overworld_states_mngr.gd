extends Node
class_name EMC_OverworldStatesMngr

signal change(changes : String)

enum Difficulty{
	TUTORIAL = 3,
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}

enum SemaphoreColors{
	RED = 0,
	YELLOW = 1,
	GREEN = 2,
}

const name_to_state : Dictionary = {
	"MobileNetState" : [MobileNetState, 4],
	"ElectricityState" : [ElectricityState, 0],
	"WaterState" : [WaterState, 1],
	"FoodContaminationState" : [FoodContaminationState, 3],
	"IsolationState" : [IsolationState, 2],
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

var _dialogue_states : Dictionary

func _ready() -> void:
	add_to_group("Save", true)

func setup(p_upgrades: Array[EMC_Upgrade]) -> void:
	_upgrades = p_upgrades

func set_dialogue_state(state_name : String, value : Variant) -> void:
	_dialogue_states[state_name] = value
	
func is_dialogue_state(state_nane : String, value : Variant) -> bool:
	if _dialogue_states.has(state_nane):
		return typeof(_dialogue_states[state_nane]) == typeof(value) and _dialogue_states[state_nane] == value
	return false

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

func get_description_by_name(scenario : String) -> Dictionary:
	if _crisis_description.has(scenario):
		return _crisis_description[scenario]
	else:
		return {"Error" : "No such Scenario"}
		
func get_description_by_index(index : int) -> Dictionary:
	return _crisis_description[_crisis_description.keys()[index]]
	
func get_description() -> Dictionary:
	return _crisis_description
	
func set_description(p_crisis_description : Dictionary) -> void:
	_crisis_description = p_crisis_description 
	
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
	change.emit("ElectricityState." + ElectricityState.find_key(_electricity_state))

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
		IsolationState.NONE: return "Keine Betretsverbote."
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
		MobileNetState.ONLINE: return "Online."
		MobileNetState.OFFLINE: return "Offline!"
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
		change.emit("WaterState." + WaterState.find_key(_water_state))
	elif "ElectricityState" in state:
		_electricity -= 1
		if _electricity == 0:
			_electricity_state = ElectricityState.UNLIMITED
		change.emit("ElectricityState." + ElectricityState.find_key(_electricity_state))
	elif "FoodContaminationState" in state:
		_food -= 1
		if _food == 0:
			_food_contamination_state = FoodContaminationState.NONE
		change.emit("FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state))
	elif "IsolationState" in state:
		_isolation[IsolationState.get(state.get_extension())] -= 1
		if _isolation[0] == 0:
			_isolation_state = IsolationState.LIMITED_PUBLIC_ACCESS
			if _isolation[1] == 0:
				_isolation_state = IsolationState.NONE
		change.emit("FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state))
	elif "MobileNetState" in state:
		_mobile -= 1
		if _mobile == 0:
			_mobilenet_state =  MobileNetState.ONLINE
		change.emit("MobileNetState." + MobileNetState.find_key(_mobilenet_state))

func add_any_state_by_name(state : String) -> void:
	if "WaterState" in state:
		var _state : WaterState = WaterState.get(state.get_extension())
		if _water_state > _state:
			_water_state = _state
			_water[_state] += 1
		change.emit("WaterState." + WaterState.find_key(_water_state))
	elif "ElectricityState" in state:
		var _state : ElectricityState = ElectricityState.get(state.get_extension())
		if _electricity_state > _state:
			_electricity_state = _state
			_electricity += 1
		change.emit("ElectricityState." + ElectricityState.find_key(_electricity_state))
	elif "FoodContaminationState" in state:
		var _state : FoodContaminationState = FoodContaminationState.get(state.get_extension())
		if _food_contamination_state > _state:
			_food_contamination_state = _state
			_food += 1
		change.emit("FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state))
	elif "IsolationState" in state:
		var _state : IsolationState = IsolationState.get(state.get_extension())
		if _isolation_state > _state:
			_isolation_state = _state
			_isolation[_state] += 1
		change.emit("FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state))
	elif "MobileNetState" in state:
		var _state : MobileNetState = MobileNetState.get(state.get_extension())
		if _mobilenet_state > _state:
			_mobilenet_state = _state
			_mobile += 1
		change.emit("MobileNetState." + MobileNetState.find_key(_mobilenet_state))

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
	
	change.emit(state)

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
		"difficulty_crisis" : _difficulty_crisis,
		"run_length" : _run_length,
		"crisis_description" : _crisis_description,
		"water_state" : _water_state,
		"isolation_state" : _isolation_state,
		"food_contamination_state" : _food_contamination_state,
		"electricity_state" : _electricity_state,
	}
	return data

## Load all relevant information. This is used for Saving/loading
func load_state(data : Dictionary) -> void:
	var p_difficulty_crisis : Difficulty = data.get("difficulty_crisis")
	var p_run_length : int = data.get("run_length")
	
	set_crisis_difficulty(p_run_length, p_difficulty_crisis)
						
	var p_water_state : WaterState = data.get("water_state")
	var p_isolation_state : IsolationState = data.get("isolation_state")
	var p_food_contamination_state : FoodContaminationState = data.get("food_contamination_state")
	var p_electricity_state : ElectricityState = data.get("electricity_state")
	
	_set_all_states(p_water_state, p_isolation_state, p_food_contamination_state, p_electricity_state)
	
	var p_crisis_description : Dictionary = data.get("crisis_description")
	
	set_description(p_crisis_description)
	
## This function sets all states without verification, it is needed to load save files
func _set_all_states(p_water_state : WaterState, p_isolation_state : IsolationState,
					p_food_contamination_state : FoodContaminationState, p_electricity_state : ElectricityState) -> void:
	_water_state = p_water_state
	_isolation_state = p_isolation_state
	_food_contamination_state = p_food_contamination_state
	_electricity_state = p_electricity_state
