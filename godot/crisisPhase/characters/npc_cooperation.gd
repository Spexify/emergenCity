extends EMC_NPC_Idee
class_name EMC_NPC_Cooperation

@onready var npc : EMC_NPC = $"../.." 

var _action: Array[String]

func _ready() -> void:
	npc.add_comp(self)

func request_cooperation(action: String) -> void:
	_action.append(action)
	
func supply_actions() -> Array[String]:
	var tmp := _action.duplicate()
	_action.clear()
	return tmp
