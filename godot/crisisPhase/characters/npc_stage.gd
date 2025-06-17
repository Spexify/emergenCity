extends Node
class_name EMC_NPC_Stage

@export var positions: Dictionary
@export var _stage_name: String = "park"

@onready var npc : EMC_NPC = $".."

var _stage_mngr: EMC_StageMngr

var _override: Vector2 = Vector2.INF
var _position: Vector2 = Vector2.INF

func _init(dict: Dictionary) -> void:
	for stage_name: String in dict.get("positions", {}):
		positions[stage_name] = EMC_Util.dict_to_vector(dict["positions"][stage_name], TYPE_VECTOR2)
	_stage_name = (dict.get("start", "") as String).to_snake_case()

func _ready() -> void:
	npc.add_comp(self)
	_stage_mngr = npc.get_stage_mngr()
	_stage_mngr.stage_changed.connect(_on_stage_changed)

func get_stage_name() -> String:
	return _stage_name
	
func change_stage(stage_name : String, wait: bool = true) -> void:
	_stage_name = stage_name
	
	if not wait:
		_stage_mngr.get_stage()._create_navigation_layer_tiles()

		_on_stage_changed(_stage_mngr.get_curr_stage_name())
	
func override_spawn(position: Vector2) -> void:
	_override = position

func change_stage_pos(stage_name: String, data: Dictionary, wait: bool = true) -> void:
	_position = EMC_Util.dict_to_vector(data, TYPE_VECTOR2)

	change_stage(stage_name, wait)

func _on_stage_changed(stage_name: String) -> void:
	#print("Current stage %s, my stage " % stage_name + _stage_name)
	if _override.is_finite():
		_stage_name = stage_name
		var postion : Vector2 = _stage_mngr.get_stage().reserve_spawn_pos(_override)
		npc.set_position(postion)
		npc.enable()
		_override = Vector2.INF
		_position = Vector2.INF
		return
	
	if stage_name == _stage_name:
		var position : Vector2
		if _position.is_finite():
			position = _stage_mngr.get_stage().reserve_spawn_pos(_position)
		else:
			position = _stage_mngr.get_stage().reserve_spawn_pos(positions.get(stage_name.to_pascal_case(), Vector2.ZERO))
		npc.set_position(position)
		npc.enable()
	else:
		npc.disbale()
	_position = Vector2.INF
