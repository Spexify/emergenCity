extends EMC_ItemComponent
class_name EMC_IC_Pleasurable
## For unenjoyable or enjoyable food or drink items

const UNIT: String = " Glück"
var _happinness_change: int

########################################## PUBLIC METHODS ##########################################
func _init(_p_happinness_change : int) -> void:
	super("Köstlich", Color.HOT_PINK)
	_happinness_change = _p_happinness_change


## Get the internal nutritionness value
func get_happinness_change() -> int:
	return _happinness_change


## Get the hydration value scaled to fit real-life units
func get_unit_happinness_change() -> int:
	return get_happinness_change() * EMC_Avatar.UNIT_FACTOR_HAPPINNESS


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return get_name() + "(" + str(get_unit_happinness_change()) + UNIT + ")"


########################################## PRIVATE METHODS #########################################
