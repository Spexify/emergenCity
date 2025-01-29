extends EMC_IC_Consumable
class_name EMC_IC_Hydrating
## For unenjoyable or enjoyable food or drink items

const UNIT: String = "Lecker"
var _hydration_change: int

########################################## PUBLIC METHODS ##########################################
func _init(_p_hydration_change : int) -> void:
	super("Hydrierend", Color.HOT_PINK)
	_hydration_change = _p_hydration_change

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.update_hydration(self.get_hydration_change())	

## Get the internal nutritionness value
func get_hydration_change() -> int:
	return _hydration_change


## Get the hydration value scaled to fit real-life units
func get_unit_hydration_change() -> int:
	return get_hydration_change() * EMC_Avatar.UNIT_FACTOR_HYDRATION


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _hydration_change < 0:
		return "De" + name.to_lower() + "(" + str(get_unit_hydration_change()) + UNIT + ")"
	else:
		return name + "(" + str(get_unit_hydration_change()) + UNIT + ")"

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "hydrating",
		"params": _hydration_change,
	}
	return data

########################################## PRIVATE METHODS #########################################
