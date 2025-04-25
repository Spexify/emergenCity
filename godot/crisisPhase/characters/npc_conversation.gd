extends EMC_NPC_Interaction_Option
class_name EMC_NPC_Conversation

@export var npc_pitch: float = 1.0
@export var tags: Array[String]

@onready var npc: EMC_NPC = $"../.."

var _gui_mngr: EMC_GUIMngr

func _init(dict: Dictionary) -> void:
	npc_pitch = dict.get("pitch", 1.0)

func _ready() -> void:
	_gui_mngr = npc.get_gui_mngr()
	npc.add_comp(self)

func get_title() -> String:
	return "Reden"

func run() -> void:
	var npc_name : String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	var stage_name: String = npc.get_comp(EMC_NPC_Stage).get_stage_name()
	
	_gui_mngr.request_gui("DialogueGui", [{"stage_name": stage_name, "actor_name": npc_name}])

func get_pitch() -> float:
	return npc_pitch

## TODO: tag ramove functionality
func add_tag(tag: String) -> void:
	tags.append(tag)

## TODO: tag ramove functionality
func has_tag(tag: String) -> bool:
	if tag in tags:
		tags.erase(tag)
		return true
	return false

func remove_tag(tag: String) -> void:
	tags.erase(tag)
