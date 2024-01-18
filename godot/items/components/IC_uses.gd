extends EMC_ItemComponent
class_name EMC_IC_Uses

var _uses_left : int = 0
var _MAX_USES : int = 0

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(_p_max_uses : int) -> void:
	super("Uses", Color.AQUAMARINE)
	_MAX_USES = _p_max_uses
	_uses_left = _p_max_uses

func get_uses_left() -> int:
	return _uses_left

func get_max_uses() -> int: 
	return _MAX_USES
	
func item_used(_p_uses : int = 1) -> int:
	if _uses_left - _p_uses > 0 :
		return _uses_left - _p_uses
	else: 
		return 0
	
func get_name_with_values() -> String:
	return str(_uses_left) + "uses left"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
