extends EMC_ItemComponent
class_name EMC_IC_Healthy
## For unenjoyable or enjoyable food or drink items

const UNIT: String = " Gesundheit"
var _health_change: int

########################################## PUBLIC METHODS ##########################################
func _init(_p_health_change : int) -> void:
	super("Gesund", Color.HOT_PINK)
	_health_change = _p_health_change


## Get the internal nutritionness value
func get_health_change() -> int:
	return _health_change


## Get the hydration value scaled to fit real-life units
func get_unit_health_change() -> int:
	return get_health_change() * EMC_Avatar.UNIT_FACTOR_HEALTH


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _health_change < 0:
		return "Un" + get_name().to_lower() + "(" + str(get_unit_health_change()) + UNIT + ")"
	else:
		return get_name() + "(" + str(get_unit_health_change()) + UNIT + ")"



########################################## PRIVATE METHODS #########################################
