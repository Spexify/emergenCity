extends EMC_NPC_Idee
class_name EMC_NPC_Quest

@export var actions: Array[Dictionary] = []

@onready var npc : EMC_NPC = $"../.." 

func _init(data: Dictionary) -> void:
	actions.assign(data.get("actions", actions))

func _ready() -> void:
	npc.add_comp(self)

func supply_actions() -> Array[String]:
	var filtered: Array[String] = check(actions)
	return filtered

func add_quest(id: String, stage: int = 1) -> void:
	OverworldStatesMngr.add_quest(id, stage)
	
func has_quest(id: String) -> bool:
	return OverworldStatesMngr.has_quest(id)

func remove_quest(id: String) -> void:
	OverworldStatesMngr.remove_quest(id)

func check(actions: Array[Dictionary]) -> Array[String]:
	var active_quest: Array[String]
	active_quest.assign(actions
	.filter(func (data: Dictionary) -> bool: return (OverworldStatesMngr.has_quest(data["quest"]) 
		and OverworldStatesMngr.get_quest_stage(data["quest"]) == data["stage"]))
	.map(func (data: Dictionary) -> String: return data["action"]))
	
	if not active_quest.is_empty():
		return active_quest
		
	if OverworldStatesMngr.next_quest():
		active_quest.assign(actions
			.filter(func (data: Dictionary) -> bool: return (data["stage"] == 0 and randf() < data["chance"]))
			.map(func (data: Dictionary) -> String: return data["action"]))
		return active_quest
	
	return []
