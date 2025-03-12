extends Node
class_name EMC_NPC_Interaction

@onready var npc : EMC_NPC = $".."

var _inter_dict: Dictionary 

func _init(data : Dictionary) -> void:
	var sub_comps_data: Dictionary = data
	
	for comp_name: String in sub_comps_data:
		var comp_class: Resource = load("res://crisisPhase/characters/npc_" + comp_name + ".gd")
		var new_comp: Variant = comp_class.new(sub_comps_data[comp_name])
		if new_comp != null:
			_inter_dict[new_comp.get_title()] = new_comp

func _ready() -> void:
	npc.add_comp(self)
	
	for sub: EMC_NPC_Interaction_Option in _inter_dict.values():
		self.add_child(sub)

func get_interactions() -> Dictionary:
	return _inter_dict

var title: String

func get_title() -> String:
	return title

func run() -> void:
	pass
