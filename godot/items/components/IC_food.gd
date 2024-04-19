extends EMC_ItemComponent
class_name EMC_IC_Food

const UNIT: String = "kcal"
const UNIT_FACTOR: int = 250 #1 Unit = 250kcal
var _nutritionness: int = 0

########################################## PUBLIC METHODS ##########################################
func _init(nutritionness: int, pleasurable: int = 0) -> void:
	super(tr("Essen"), Color.INDIAN_RED)
	_nutritionness = nutritionness
	

## Get the internal nutritionness value
func get_nutritionness() -> int:
	return _nutritionness


## Get the nutritionness value scaled to fit real-life units
func get_unit_nutritionness() -> int:
	return _nutritionness * UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return name + " (" + str(get_unit_nutritionness()) + UNIT + ")"

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "food",
		"params": _nutritionness,
	}
	return data

########################################## PRIVATE METHODS #########################################
