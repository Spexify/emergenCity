extends Node
class_name EMC_OverworldStatesMngr

var _electricity_state: bool

enum WaterState{
	CLEAN = 0,
	DIRTY = 1,
	NONE = 2
}

var _water_state: WaterState

enum Furniture{
	RAINWATER_BARREL = 0,
	ELECTRIC_RADIO = 1,
}

var _upgrades: Array[Furniture]

var _furniture_state : Dictionary = {
	Furniture.RAINWATER_BARREL : 0,
}
# All furniture_states range between 0 and the furniture_state_maximum defined here
const _furniture_state_maximum : Dictionary = {
	Furniture.RAINWATER_BARREL : 5,
}

func get_electricity_state() -> bool:
	return _electricity_state

func set_electricity_state(new_electricity_state: bool) -> void:
	_electricity_state = new_electricity_state
	
func get_water_state() -> WaterState:
	return _water_state

func set_water_state(new_water_state: WaterState) -> void:
	_water_state = new_water_state
	
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
