extends EMC_ItemComponent
class_name EMC_IC_Drink

const UNIT: String = "ml"
var _hydration: int = 0 #Wie sehr man hydriert wird

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(hydration: int):
	super("Getränk", Color.CADET_BLUE)
	_hydration = hydration 


func get_hydration() -> int:
	return _hydration


func get_name_with_values() -> String:
	return get_name() + " (" + str(_hydration) + UNIT + ")"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
