extends EMC_NPC_Idee
class_name EMC_NPC_Impulsive

@export var actions: Dictionary
@export var random: Dictionary

func _init(data : Dictionary) -> void:
	actions = data.get("actions", {})
	random = data.get("count", {})

func supply_actions() -> Array[String]:
	var weight: Array[float]
	weight.assign(random.values())
	var count: int = EMC_Util.pick_weighted_random(random.keys(), weight, 1)[0].to_int()
	weight.assign(actions.values())
	var result: Array[String]
	result.assign(EMC_Util.pick_weighted_random(actions.keys(), weight, count))
	
	return result
