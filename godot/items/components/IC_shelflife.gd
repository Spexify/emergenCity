extends EMC_ItemComponent
class_name EMC_IC_Shelflife

const DECAY_RATE_NO_ELECTRICITY: int = 2
const DECAY_RATE_WITH_ELECTRICITY: int = 1
const UNIT: String = " Tage"
var _shelflife: int 


########################################## PUBLIC METHODS ##########################################
func _init(_p_max_shelflife : int) -> void:
	super("Haltbarkeit", Color.CHOCOLATE)
	_shelflife = _p_max_shelflife


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
		_shelflife -= DECAY_RATE_NO_ELECTRICITY
		if _shelflife < 0: _shelflife = 0
	else:
		_shelflife -= DECAY_RATE_WITH_ELECTRICITY


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if is_spoiled():
		return get_name() + ": Verdorben"
	else:
		return get_name() + ": " + str(get_shelflife()) + UNIT


########################################## PRIVATE METHODS #########################################
