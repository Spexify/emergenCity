extends Node
class_name EMC_OverworldStatesMngr

var _crisis_length : int = 3 #Length of entire crisis phase, name could be changed to max_day or so
var _number_crisis_overlap : int = 3
var _allowed_water_crisis : WaterState
var _allowed_electricity_crisis : ElectricityState
var _allowed_isolation_crisis : IsolationState
var _allowed_food_contamination_crisis : FoodContaminationState
var _scenario_name : String = ""
var _active_crises_descr: String = ""
var _notification: String

enum SemaphoreColors{
	RED = 0,
	YELLOW = 1,
	GREEN = 2,
}

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

func _ready() -> void:
	add_to_group("Save", true)

func setup(p_upgrades: Array[EMC_Upgrade]) -> void:
	_upgrades = p_upgrades


## Idea: instead of all the members of EMC_CrisisScenario, just pass one reference of it to there
## This way, it is more ordered, and you can still access all the necessary data through the CrisisScenario object!
func set_crisis_difficulty(p_scenario_name : String = "", _p_water_crisis: WaterState = WaterState.CLEAN, _p_electricity_crisis : ElectricityState = ElectricityState.UNLIMITED,
							_p_isolation_crisis : IsolationState = IsolationState.NONE, _p_food_contamination_crisis : FoodContaminationState = FoodContaminationState.NONE,
						_p_crisis_length : int = 2, _p_number_crisis_overlap : int = 2, p_notification : String = "") -> void:
	_allowed_water_crisis = _p_water_crisis
	_allowed_electricity_crisis =_p_electricity_crisis
	_allowed_isolation_crisis = _p_isolation_crisis
	_allowed_food_contamination_crisis = _p_food_contamination_crisis
	_scenario_name = p_scenario_name
	_crisis_length = _p_crisis_length
	_number_crisis_overlap = _p_number_crisis_overlap
	_notification = p_notification
	
	print("Crisis length:" + str(_crisis_length))
	
	#if !Global._tutorial_done:
		#_electricity_state = ElectricityState.NONE

func get_number_crisis_overlap() -> int:
	return _number_crisis_overlap


func get_crisis_length() -> int:
	return _crisis_length


## Returns scenario name
func get_scenario_name() -> String:
	return _scenario_name


## Returns notification for radio
func get_notification() -> String:
	return _notification


## Not really nicely solved, but no time lol
func clear_active_crises_descr() -> void:
	_active_crises_descr = ""


## Returns a concatenation of all active crises
func get_active_crises_descr() -> String:
	var res := _active_crises_descr
	if res != "":
		res = "Ohje..." + res
	return res


func get_water_crisis_status() -> WaterState:
	return _allowed_water_crisis


func get_electricity_crisis_status() -> ElectricityState:
	return _allowed_electricity_crisis


func get_isolation_crisis_status() -> IsolationState:
	return _allowed_isolation_crisis


func get_food_contamination_crisis_status() -> FoodContaminationState:
	return _allowed_food_contamination_crisis


func get_electricity_state() -> ElectricityState:
	return _electricity_state


func set_electricity_state(new_electricity_state: ElectricityState) -> void:
	_electricity_state = new_electricity_state
	match _electricity_state:
		ElectricityState.NONE: _active_crises_descr += " Der Strom ist ausgefallen!"
		ElectricityState.UNLIMITED: pass


func get_electricity_state_descr() -> String:
	match _electricity_state:
		ElectricityState.NONE: return "Ausgefallen!"
		ElectricityState.UNLIMITED: return "Vorhanden."
	return ""


func get_water_state() -> WaterState:
	return _water_state


func set_water_state(new_water_state: WaterState) -> void:
	_water_state = new_water_state
	match _water_state:
		WaterState.NONE: _active_crises_descr += " Das Wasser ist komplett ausgefallen!"
		WaterState.DIRTY: _active_crises_descr += " Nur verunreinigtes Wasser fließt aus der Leitung!"
		WaterState.CLEAN: pass


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
	match _isolation_state:
		IsolationState.NONE: pass
		IsolationState.LIMITED_PUBLIC_ACCESS: _active_crises_descr += " Ein Betretungsverbot öffentlicher Gelände wurde verhangen!"
		IsolationState.ISOLATION: _active_crises_descr += " Eine Quarantäne wurde angeordnet!"


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
	match _food_contamination_state:
		FoodContaminationState.NONE: pass
		FoodContaminationState.FOOD_SPOILED: _active_crises_descr += " Die Essensvorräte sind allesamt verdorben!"


func get_food_contamination_state_descr() -> String:
	match _food_contamination_state:
		FoodContaminationState.NONE:
			if _electricity_state == ElectricityState.NONE:
				return "Reduzierte Haltbarkeit (Kühlschrank ohne Strom)"
			else: return "Kein Problem."
		FoodContaminationState.FOOD_SPOILED: return "Kontaminiert!"
	return ""


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

## Save function called to get all relevant information. This is used for Saving/loading
func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		"allowed_water_crisis" : _allowed_water_crisis,
		"allowed_electricity_crisis" : _allowed_electricity_crisis, 
		"allowed_isolation_crisis" : _allowed_isolation_crisis,
		"allowed_food_contamination_crisis" : _allowed_food_contamination_crisis,
		"scenario_name" : _scenario_name,
		"crisis_length" : _crisis_length,
		"number_crisis_overlap" : _number_crisis_overlap,
		"notification" : _notification,
		"water_state" : _water_state,
		"isolation_state" : _isolation_state,
		"food_contamination_state" : _food_contamination_state,
		"electricity_state" : _electricity_state,
	}
	return data

## Load all relevant information. This is used for Saving/loading
func load_state(data : Dictionary) -> void:
	var p_water_crisis : WaterState = data.get("allowed_water_crisis")
	var p_electricity_crisis : ElectricityState = data.get("allowed_electricity_crisis")
	var p_isolation_crisis : IsolationState = data.get("allowed_isolation_crisis")
	var p_food_contamination_crisis : FoodContaminationState = data.get("allowed_food_contamination_crisis")
	var p_scenario_name : String = data.get("scenario_name")
	var p_crisis_length : int = data.get("crisis_length")
	var p_number_crisis_overlap : int = data.get("number_crisis_overlap")
	var p_notification : String = data.get("notification")
	
	set_crisis_difficulty(p_scenario_name, p_water_crisis, p_electricity_crisis,
							p_isolation_crisis, p_food_contamination_crisis,
						p_crisis_length, p_number_crisis_overlap, p_notification)
						
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
