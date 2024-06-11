extends EMC_IC_Consumable
class_name EMC_IC_Pleasurable
## For unenjoyable or enjoyable food or drink items

const UNIT: String = "ICU_HAPPY"
var _happiness_change: int

########################################## PUBLIC METHODS ##########################################
func _init(_p_happiness_change : int) -> void:
	super(tr("Köstlich"), Color.HOT_PINK)
	_happiness_change = _p_happiness_change

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.update_happiness(self.get_happiness_change())	

## Get the internal nutritionness value
func get_happiness_change() -> int:
	return _happiness_change


## Get the hydration value scaled to fit real-life units
func get_unit_happiness_change() -> int:
	return get_happiness_change() * EMC_Avatar.UNIT_FACTOR_HAPPINESS


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return name + "(" + str(get_unit_happiness_change()) + " " + tr(UNIT) + ")"


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "pleasurable",
		"params": _happiness_change,
	}
	return data

########################################## PRIVATE METHODS #########################################
