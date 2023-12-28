extends EMC_Action
class_name EMC_StageChangeAction

var _stage_name: String
var _spawn_pos: Vector2i

func _init(p_action_ID: int, p_action_name : String, p_constraints_prior : Dictionary, p_description : String,
			p_stage_name: String, p_spawn_pos: Vector2i):
	super(p_action_ID, p_action_name, p_constraints_prior, {}, "ChangeStageGUI", p_description)
	_stage_name = p_stage_name
	_spawn_pos = p_spawn_pos


func get_stage_name() -> String:
	return _stage_name


func get_spawn_pos() -> Vector2i:
	return _spawn_pos
