extends EMC_ItemComponent
class_name EMC_IC_Drink

const UNIT: String = "ml"
const UNIT_FACTOR: int = 500 #1 Unit = 500ml
var _hydration: int = 0 #Wie sehr man hydriert wird

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(hydration: int) -> void:
	super("Getränk", Color.CADET_BLUE)
	_hydration = hydration 


## Get the internal hydration value
func get_hydration() -> int:
	return _hydration


## Get the hydration value scaled to fit real-life units
func get_unit_hydration() -> int:
	return _hydration * UNIT_FACTOR


func get_formatted_values() -> String:
	return get_name() + " (" + str(get_unit_hydration()) + UNIT + ")"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
