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


func no_uses_left() -> bool:
	return get_uses_left() <= 0


func get_uses_left() -> int:
	return _uses_left


func get_max_uses() -> int: 
	return _MAX_USES


## MRM: Renamed from "item_used" to "use_item", as the past-timetense implicitly 
## suggests it is a signal not a function
func use_item(_p_uses : int = 1) -> void:
	_uses_left -=_p_uses
	if _uses_left < 0 :
		_uses_left = 0
 	
	
func get_name_with_values() -> String:
	return str(_uses_left) + " Nutzungen übrig."


#----------------------------------------- PRIVATE METHODS -----------------------------------------
