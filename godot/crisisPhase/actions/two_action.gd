extends EMC_Action
class_name EMC_TwoAction

func _init(p_action_ID: int, p_action_name : String, p_constraints : Array[Dictionary],
			p_consequences : Array[Dictionary], p_description : Array[String],
			p_prompt: String, p_coin : Array[int], p_progresses_day_period : Array[bool] = [true, true],
			p_sound : Array[String] = ["BasicItem", "BasicItem"]) -> void:
	super(p_action_ID, p_action_name, p_constraints[0], p_consequences[0], "TwoAction",
	p_description[0], p_prompt, p_coin[0], p_progresses_day_period[0], p_sound[0])


static func from_dict(data : Dictionary) -> EMC_Action:
	var _action_id : int = data.get("id")
	var _action_name : String = data.get("name", "")
	var _constraints : Array[Dictionary]
	_constraints.assign(data.get("constraints", [{}, {}]))
	var _consequences : Array[Dictionary]
	_consequences.assign(data.get("consequences",[{}, {}]))
	var _description : Array[String]
	_description.assign(data.get("description", ["", ""]))
	var _e_coin : Array[int]
	_e_coin.assign(data.get("e_coin", [0, 0]))
	var _silent : Array[bool]
	_silent.assign(not data.get("silent", [false, false]))
	var sound : Array[String]
	sound.assign(data.get("sound", ["BasicItem", "BasicItem" ]))
	var _prompt : String = data.get("prompt", "") 
	
	return EMC_TwoAction.new(_action_id, _action_name, _constraints, _consequences, _description, _prompt, _e_coin, _silent, sound)
