extends EMC_Action
class_name EMC_StageChangeAction

var _stage_name: String
var _avatar_spawn_pos: Vector2i
var _NPCs_spawn_pos: Dictionary


func _init(p_action_ID: int, p_action_name : String, p_constraints_prior : Dictionary, p_description : String,
			p_performance_coin_value : int, p_stage_name: String, p_avatar_spawn_pos: Vector2i,
			p_NPCs_spawn_pos: Dictionary) -> void:
	super(p_action_ID, p_action_name, p_constraints_prior, {}, "ChangeStageGUI", p_description, p_performance_coin_value)
	_stage_name = p_stage_name
	_avatar_spawn_pos = p_avatar_spawn_pos
	_NPCs_spawn_pos = p_NPCs_spawn_pos


func get_stage_name() -> String:
	return _stage_name


func get_avatar_spawn_pos() -> Vector2i:
	return _avatar_spawn_pos


func get_NPCs_spawn_pos() -> Dictionary:
	return _NPCs_spawn_pos
