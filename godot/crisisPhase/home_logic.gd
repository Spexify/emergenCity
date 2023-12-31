extends Node
class_name EMC_HomeLogic

var _electricity_state: bool

enum WaterState{
	CLEAN = 0,
	DIRTY = 1,
	NONE = 2
}

#TODO: List of present upgrades/furniture
enum Upgrade{
	RADIO = 0,
	RAINWATER_BARREL = 1
}

var _upgrades: Array[Upgrade]

var _water_state: WaterState

func get_electricity_state() -> bool:
	return _electricity_state

func set_electricity_state(new_electricity_state: bool) -> void:
	_electricity_state = new_electricity_state
	
func get_water_state() -> WaterState:
	return _water_state

func set_water_state(new_water_state: WaterState) -> void:
	_water_state = new_water_state
	
func get_upgrades() -> Array[Upgrade]:
	return _upgrades

func set_upgrades(new_upgrades: Array[Upgrade]) -> void:
	_upgrades = new_upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass
