extends Node
class_name EMC_ActionExecuter

var _function : Callable

func _init(p_function : Callable) -> void:
	_function = p_function

func execute(p_name : String) -> void:
	var act : EMC_Action = JsonMngr.name_to_action(p_name)
	if act != null:
		act.executed.connect(_function)
		act.executed.emit(act)
