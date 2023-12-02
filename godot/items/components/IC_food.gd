extends EMC_ItemComponent
class_name EMC_IC_Food

const UNIT: String = "kcal"
var _nutritionness: int = 0 #Nahrhaftigkeit

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(nutritionness: int):
	super("Essen", Color.INDIAN_RED)
	_nutritionness = nutritionness 


func get_nutritionness() -> int:
	return _nutritionness


func get_name_with_values() -> String:
	return get_name() + " (" + str(_nutritionness) + UNIT + ")"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
