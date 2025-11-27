extends Resource
class_name EMC_NPC_Interaction

@export var interactions: Dictionary[String, EMC_NPC_Interaction_Option] 

func setup(data: Dictionary) -> void:
	var sub_comps_data: Dictionary = data
	
	for comp_name: String in sub_comps_data:
		var comp_class: Resource = load("res://crisisPhase/npc/npc_" + comp_name + ".gd")
		var new_comp: Variant = comp_class.new()
		if new_comp != null:
			new_comp.setup(sub_comps_data[comp_name])
			interactions[new_comp.get_title()] = new_comp

func get_interactions() -> Dictionary:
	return interactions
