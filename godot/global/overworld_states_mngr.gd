extends Node
class_name EMC_OverworldStatesMngr

var _crisis_length : int = 3
var _number_crisis_overlap : int = 3
var _water_crisis_status : WaterState
var _electricity_crisis_status : ElectricityState
var _isolation_crisis_status : IsolationState
var _food_contamination_crisis_status : FoodContaminationState
var _notification : String = ""

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
						_p_crisis_length : int = 2, _p_number_crisis_overlap : int = 2, _p_notification : String = "") -> void:
	_water_crisis_status = _p_water_crisis
	_electricity_crisis_status =_p_electricity_crisis
	_isolation_crisis_status = _p_isolation_crisis
	_food_contamination_crisis_status = _p_food_contamination_crisis
	_notification = _p_notification

	_crisis_length = _p_crisis_length
	_number_crisis_overlap = _p_number_crisis_overlap

	#if !Global._tutorial_done:
		#_electricity_state = ElectricityState.NONE

func get_number_crisis_overlap() -> int:
	return _number_crisis_overlap

func get_crisis_length() -> int:
	return _crisis_length

func get_crisis_notification() -> String:
	return _notification

func get_water_crisis_status() -> WaterState:
	return _water_crisis_status

func get_electricity_crisis_status() -> ElectricityState:
	return _electricity_crisis_status

func get_isolation_crisis_status() -> IsolationState:
	return _isolation_crisis_status

func get_food_contamination_crisis_status() -> FoodContaminationState:
	return _food_contamination_crisis_status

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
		FoodContaminationState.NONE: return "Kein Problem."
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
		if upgrade.get_id() == p_upgrade_id:
			upgrade.set_state(new_state)
	push_error("Upgrade nicht ausgerüstet!")

func get_furniture_state_maximum(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade.get_id() == p_upgrade_id:
			return upgrade.get_state_maximum()
	push_error("Upgrade nicht ausgerüstet!")
	return -1
