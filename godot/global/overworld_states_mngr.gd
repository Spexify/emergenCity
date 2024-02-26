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

enum SemaphoreColors{
	RED = 0,
	YELLOW = 1,
	GREEN = 2,
}

enum ElectricityState{
	NONE = SemaphoreColors.RED,
	UNLIMITED = SemaphoreColors.GREEN
}
var _electricity_state: ElectricityState = ElectricityState.NONE

enum WaterState{
	NONE = SemaphoreColors.RED,
	DIRTY = SemaphoreColors.YELLOW,
	CLEAN = SemaphoreColors.GREEN
}

var _water_state: WaterState = WaterState.NONE

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

func setup(p_electricity_state: ElectricityState, p_water_state: WaterState, p_upgrades: Array[EMC_Upgrade]) -> void:
	_electricity_state = p_electricity_state
	_water_state = p_water_state
	_upgrades = p_upgrades

func set_crisis_difficulty(_p_water_crisis: WaterState = WaterState.CLEAN, _p_electricity_crisis : ElectricityState = ElectricityState.UNLIMITED,
							_p_isolation_crisis : IsolationState = IsolationState.NONE, _p_food_contamination_crisis : FoodContaminationState = FoodContaminationState.NONE,
						_p_crisis_length : int = 2, _p_number_crisis_overlap : int = 2, p_scenario_name : String = "") -> void:
	_allowed_water_crisis = _p_water_crisis
	_allowed_electricity_crisis =_p_electricity_crisis
	_allowed_isolation_crisis = _p_isolation_crisis
	_allowed_food_contamination_crisis = _p_food_contamination_crisis
	_scenario_name = p_scenario_name

	_crisis_length = _p_crisis_length
	_number_crisis_overlap = _p_number_crisis_overlap

	#if !Global._tutorial_done:
		#_electricity_state = ElectricityState.NONE

func get_number_crisis_overlap() -> int:
	return _number_crisis_overlap

func get_crisis_length() -> int:
	return _crisis_length

## Returns scenario name
func get_scenario_name() -> String:
	return _scenario_name


## Not really nicely solved, but no time lol
func clear_active_crises_descr() -> void:
	_active_crises_descr = ""


## Returns a concatenation of all active crises
func get_active_crises_descr() -> String:
	var res := _active_crises_descr
	if res != "":
		res = "Ohje... " + res
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
		ElectricityState.NONE: _active_crises_descr += "Der Strom ist ausgefallen!"
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
		WaterState.NONE: _active_crises_descr += "Das Wasser ist komplett ausgefallen!"
		WaterState.DIRTY: _active_crises_descr += "Nur verunreinigtes Wasser fließt aus der Leitung!"
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
		IsolationState.LIMITED_PUBLIC_ACCESS: _active_crises_descr += "Ein Betretungsverbot öffentlicher Gelände wurde verhangen!"
		IsolationState.ISOLATION: _active_crises_descr += "Eine Quarantäne wurde angeordnet!"


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
		FoodContaminationState.FOOD_SPOILED: _active_crises_descr += "Die Essensvorräte sind allesamt verdorben!"


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
