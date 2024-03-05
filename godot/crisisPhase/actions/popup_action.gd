extends EMC_Action
class_name EMC_PopUpAction

var _pop_up_text : String
var _cancel_consequences : Dictionary

func _init(p_action_ID: int, p_action_name : String, p_constraints_prior : Dictionary,
 p_consequences : Dictionary, p_cancel_consequences : Dictionary, p_description : String, p_performance_coin_value : int,
 p_pop_up_text : String, p_type_gui : String, p_progresses_day_period : bool = true) -> void:
	super(p_action_ID, p_action_name, p_constraints_prior, p_consequences, p_type_gui, p_description, "", p_performance_coin_value, p_progresses_day_period)
	_pop_up_text = p_pop_up_text
	_cancel_consequences = p_cancel_consequences

func get_pop_up_text() -> String :
	return _pop_up_text

static func from_dict(data : Dictionary) -> EMC_PopUpAction:
	var _action_id : int = data.get("id")
	var _action_name : String = data.get("name", "")
	var _constraints : Dictionary = data.get("constraints", {})
	var _consequences : Dictionary = data.get("consequences", {})
	var _cancel_consequences : Dictionary = data.get("cancel_consequences", {})
	var _description : String = data.get("description", "")
	var _e_coin : int = data.get("e_coin", 0)
	var _pop_up_text : String = data.get("pop_up_text", "")
	var _silent : bool = not data.get("silent", false)
	
	return EMC_PopUpAction.new(_action_id, _action_name, _constraints, _consequences, _cancel_consequences, _description, _e_coin, _pop_up_text, "PopUpGui", _silent)
