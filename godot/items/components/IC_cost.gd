extends EMC_ItemComponent
class_name EMC_IC_Cost

var _cost : int = 0


#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(cost : int) -> void:
	super("Cost", Color.GOLDENROD)
	_cost = cost

func get_cost() -> int:
	return _cost
	
func get_name_with_values() -> String:
	return str(_cost) + "eC"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
