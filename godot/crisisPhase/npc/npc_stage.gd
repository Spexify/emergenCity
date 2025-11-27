extends Resource
class_name EMC_NPC_Stage

@export var stage_name: String = "Park"
@export var position: Vector2

func setup(dict: Dictionary) -> void:
	stage_name = dict.get("stage_name", stage_name)
	position = EMC_Util.dict_to_vector(dict.get("position", {"x": 200, "y": 500}), TYPE_VECTOR2)

func change_stage(_stage_name: String, slot: Node2D) -> void:
	stage_name = _stage_name
	position = slot.global_position
