extends Node
class_name EMC_NPC_Decide

#func _init(data: Dictionary) -> void:
	#pass

func choose_option(options: Array[String]) -> String:
	return options.pick_random()
