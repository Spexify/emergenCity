extends EMC_ItemComponent
class_name EMC_IC_Drink

const UNIT: String = "ml"
const UNIT_FACTOR: int = 250 #1 Unit = 500ml
var _hydration: int = 0 

########################################## PUBLIC METHODS ##########################################
func _init(p_hydration: int) -> void:
	super("Getränk", Color.CADET_BLUE)
	_hydration = p_hydration 


## Get the internal hydration value
func get_hydration() -> int:
	return _hydration


## Get the hydration value scaled to fit real-life units
func get_unit_hydration() -> int:
	return _hydration * UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return name + " (" + str(get_unit_hydration()) + UNIT + ")"
	
func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "drink",
		"params": _hydration,
	}
	return data

########################################## PRIVATE METHODS #########################################
