extends Resource
class_name EMC_NPC_Interaction_Option

@export var title: String

func get_title() -> String:
	return title

func run(_gui_mngr: EMC_GUIMngr) -> void:
	pass
