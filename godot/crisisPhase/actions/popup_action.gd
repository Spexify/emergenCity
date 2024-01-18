extends EMC_Action
class_name EMC_PopUpAction

var _pop_up_text : String

func _init(p_action_ID: int, p_action_name : String, p_constraints_prior : Dictionary, 
			p_description : String, p_performance_coin_value : int, p_pop_up_text : String) -> void:
	super(p_action_ID, p_action_name, p_constraints_prior, {}, "", p_description, p_performance_coin_value)
	_pop_up_text = p_pop_up_text
	pass
	
func get_pop_up_text() -> String :
	return _pop_up_text

