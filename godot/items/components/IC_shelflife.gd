extends EMC_ItemComponent
class_name EMC_IC_Shelflife

const UNIT: String = " Tage"
var _shelflife: int 
var _max_shelflife: int


########################################## PUBLIC METHODS ##########################################
func _init(_p_max_shelflife : int) -> void:
	super("Haltbarkeit", Color.CHOCOLATE)
	_max_shelflife = _p_max_shelflife
	_shelflife = _max_shelflife


## Get the internal nutritionness value
func get_shelflife() -> int:
	if OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.NONE:
		# Note: When electricity is missing, the shelflife is reduced by 2 each day, and thus
		# has to be displayed by half of its amount, rounded up:
		return ceil(_shelflife / 2.0)
	else:
		return _shelflife


func is_spoiled() -> bool:
	return _shelflife <= 0


func reduce_shelflife() -> void:
	if OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.NONE:
		_shelflife -= 2 #When there is no electricity, food decays twice as fast
		if _shelflife < 0: _shelflife = 0
	else:
		_shelflife -= 1


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if is_spoiled():
		return get_name() + ": Verdorben"
	else:
		return get_name() + ": " + str(get_shelflife()) + UNIT


########################################## PRIVATE METHODS #########################################
