extends EMC_ItemComponent
class_name EMC_IC_Cost

@export var _cost : int = 0


#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(cost : int = 0) -> void:
	super("Cost", Color.GOLDENROD)
	_cost = cost


func get_cost() -> int:
	return _cost


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if Global.is_in_crisis_phase():
		return ""
	else:
		return str(_cost) + "eC"


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "cost",
		"params": _cost,
	}
	return data

#----------------------------------------- PRIVATE METHODS -----------------------------------------
