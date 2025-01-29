extends EMC_ItemComponent
class_name EMC_IC_Value

var _value : int = 0

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(value : int) -> void:
	super("Value", Color.GOLDENROD)
	_value = value


func get_value() -> int:
	return _value


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return ""


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "value",
		"params": _value,
	}
	return data

#----------------------------------------- PRIVATE METHODS -----------------------------------------
