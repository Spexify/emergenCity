extends Node
class_name EMC_ActionExecuter

var _actions : Array[EMC_Action]

func _init(p_actions : Array[EMC_Action]) -> void:
	_actions = p_actions
	
func execute(p_name : String) -> void:
	for act in _actions:
		if act.get_ACTION_NAME() == p_name:
			act.executed.emit(act)
			return
