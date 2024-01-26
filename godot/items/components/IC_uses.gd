extends EMC_ItemComponent
class_name EMC_IC_Uses

var _uses_left : int = 0
var _MAX_USES : int = 0

var _uses: String = "3 uses left"

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(_p_max_uses : int) -> void:
	super("Uses", Color.AQUAMARINE)
	_MAX_USES = _p_max_uses
	_uses_left = _p_max_uses
	set_name_with_values(_p_max_uses)
	

func get_uses_left() -> int:
	return _uses_left

func get_max_uses() -> int: 
	return _MAX_USES
	
func item_used(_p_uses : int = 1) -> void:
	if _uses_left - _p_uses > 0 :
		set_name_with_values(_uses_left - _p_uses) 
	else: 
		set_name_with_values(0)
	
	
func get_name_with_values() -> String:
	return _uses

func set_name_with_values(_p_uses: int) -> String:
	return str(_p_uses) + " uses left"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
