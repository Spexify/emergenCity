extends EMC_ItemComponent
class_name EMC_IC_Food

const UNIT: String = "kcal"
const UNIT_FACTOR: int = 500 #1 Unit = 500kcal
var _nutritionness: int = 0

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(nutritionness: int):
	super("Essen", Color.INDIAN_RED)
	_nutritionness = nutritionness 


## Get the internal nutritionness value
func get_nutritionness() -> int:
	return _nutritionness


## Get the nutritionness value scaled to fit real-life units
func get_unit_nutritionness() -> int:
	return _nutritionness * UNIT_FACTOR


func get_formatted_values() -> String:
	return get_name() + " (" + str(get_unit_nutritionness()) + UNIT + ")"

#----------------------------------------- PRIVATE METHODS -----------------------------------------