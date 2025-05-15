extends Node
class_name EMC_NPC_Save

@export var res: EMC_AllRes
@onready var npc : EMC_NPC = $".."

func _ready() -> void:
	Global.game_saved.connect(save)
	npc.add_comp(self)
	load_res.call_deferred()

func add_res(p_name: String, p_data: Variant) -> void:
	res.add_res(p_name, p_data)

func get_res(p_name: String, type: Variant) -> Variant:
	var obj: Variant = res.get_res(p_name)
	if is_instance_of(obj, type):
		return obj
	return null

func save() -> void:
	var npc_name: String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	ResourceSaver.save(res, "user://" + npc_name + ".tres")

func load_res() -> void:
	var npc_name: String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	if ResourceLoader.exists("user://" + npc_name + ".tres"):
		res = ResourceLoader.load("user://" + npc_name + ".tres")
	else:
		res = EMC_AllRes.new()
