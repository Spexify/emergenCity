extends Node
class_name EMC_NPC_Descr

@export var npc_name: String
@export var descr : String
@export var portrait: Texture2D

@onready var npc : EMC_NPC = $".."

func _init(dict: Dictionary) -> void:
	npc_name = dict.get("name", "dummy")
	descr = dict.get("descr", "Das ist Niemand")
	var texture_name: String = dict.get("portait", "dummy")
	portrait = load("res://assets/characters/portrait_" + texture_name + ".png")

func _ready() -> void:
	npc.set_name(npc_name)
	npc.add_comp(self)

func get_npc_name() -> String:
	return npc_name

func get_desc() -> String:
	return descr
	
func get_portrait() -> Texture2D:
	return portrait
