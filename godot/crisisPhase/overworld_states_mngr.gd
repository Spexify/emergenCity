extends Node
class_name EMC_OverworldStatesMngr

enum ElectricityState{
	NONE = 0,
	UNLIMITED = 1
}
var _electricity_state: ElectricityState

enum WaterState{
	NONE = 0,
	DIRTY = 1,
	CLEAN = 2
}

var _water_state: WaterState

enum IsolationState{
	NONE = 0,
	LIMITED_ACCESS_MARKET = 1,
	ISOLATION = 2
}

var _isolation_state: IsolationState

enum Furniture{
	WATER_RESERVOIR = 0, #UNUSED
	RAINWATER_BARREL = 1,
	ELECTRIC_RADIO = 2,
	CRANK_RADIO = 3,
}

var _upgrades: Array[Furniture]

var _furniture_state : Dictionary

# All furniture_states range between 0 and the furniture_state_maximum defined here
const _furniture_state_maximum : Dictionary = {
	Furniture.RAINWATER_BARREL : 24, # water quantity is in units of 250ml
}


func setup(p_electricity_state: ElectricityState, p_water_state: WaterState, p_upgrades: Array[Furniture]) -> void:
	_electricity_state = p_electricity_state
	_water_state = p_water_state
	_upgrades = p_upgrades
	_furniture_state = {
		Furniture.RAINWATER_BARREL : 0,
	}

func get_electricity_state() -> ElectricityState:
	return _electricity_state

func set_electricity_state(new_electricity_state: ElectricityState) -> void:
	_electricity_state = new_electricity_state
	
func get_water_state() -> WaterState:
	return _water_state

func set_water_state(new_water_state: WaterState) -> void:
	_water_state = new_water_state
	
func get_isolation_state() -> IsolationState:
	return _isolation_state

func set_isolation_state(new_isolation_state: IsolationState) -> void:
	_isolation_state = new_isolation_state
	
func get_upgrades() -> Array[Furniture]:
	return _upgrades

func set_upgrades(new_upgrades: Array[Furniture]) -> void:
	_upgrades = new_upgrades
	
func get_furniture_state(furniture: Furniture) -> int:
	return _furniture_state[furniture]
	
func set_furniture_state(furniture: Furniture, state: int) -> void:
	if state > _furniture_state_maximum[furniture] || state < 0:
		push_error("Unerwarteter Fehler: furniture state out of bounds")
	_furniture_state[furniture] = state
	
func get_furniture_state_maximum(furniture: Furniture) -> int:
	return _furniture_state_maximum[furniture]
