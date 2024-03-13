extends EMC_Action
class_name EMC_StageChangeAction

var _stage_name: String


func _init(p_action_ID: int, p_action_name : String, p_constraints_prior : Dictionary, p_consequences : Dictionary, p_description : String,
			p_performance_coin_value : int, p_stage_name: String, p_progresses_day_period : bool = true, p_sound : String = "BasicItem") -> void:
	super(p_action_ID, p_action_name, p_constraints_prior, p_consequences, "ChangeStageGUI", p_description, "",  p_performance_coin_value, p_progresses_day_period, p_sound)
	_stage_name = p_stage_name


func get_stage_name() -> String:
	return _stage_name


static func from_dict(data : Dictionary) -> EMC_Action:
	var _action_id : int = data.get("id")
	var _action_name : String = data.get("name", "")
	var _constraints : Dictionary = data.get("constraints", {})
	var _consequences : Dictionary = data.get("consequences",{})
	var _description : String = data.get("description", "")
	var _e_coin : int = data.get("e_coin", 0)
	var p_stage_name : String = data.get("stage_name", "home")
	var _silent : bool = not data.get("silent", false)
	var sound : String = data.get("sound", "BasicItem")
	
	return EMC_StageChangeAction.new(_action_id, _action_name, _constraints, _consequences, _description, _e_coin, p_stage_name, _silent, sound)
