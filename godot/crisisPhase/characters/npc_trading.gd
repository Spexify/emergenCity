extends EMC_NPC_Interaction_Option
class_name EMC_NPC_Trading

@export var _inventory: EMC_Inventory
@export var _item_preference: Dictionary

@onready var npc: EMC_NPC = $"../.."

var _gui_mngr: EMC_GUIMngr
var _initial_inventory: Dictionary

func _init(dict: Dictionary) -> void:
	_initial_inventory = dict.get("inventory", {})
	_item_preference = dict.get("preferences", {})

func _ready() -> void:
	Global.game_saved.connect(save)
	_gui_mngr = npc.get_gui_mngr()
	npc.add_comp(self)
	load_inventory.call_deferred()

func get_title() -> String:
	return "Handeln"

func run() -> void:
	_gui_mngr.request_gui("Trade", [npc])

func get_inventory() -> EMC_Inventory:
	return _inventory
	
func load_inventory() -> void:
	var npc_name: String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	if ResourceLoader.exists("user://" + npc_name + "_inventory.tres"):
		_inventory = ResourceLoader.load("user://" + npc_name + "_inventory.tres", "EMC_Inventory")
	else:
		_inventory = EMC_Inventory.new(18)
		for item_name : String in _initial_inventory.keys():
			for i : int in range(_initial_inventory[item_name] as int):
				_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))
	
func save() -> void:
	if _inventory != null:
		var npc_name: String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
		ResourceSaver.save(_inventory, "user://" + npc_name + "_inventory.tres")

func calulate_item_score_generic(items : Array[EMC_Item], modifier : Dictionary) -> float:
	return items.reduce(
		func (accum : int, item : EMC_Item) -> int:
			var value_comp := item.get_comp(EMC_IC_Value)
			accum += modifier.get(JsonMngr.item_id_to_name(item.get_id()), 1) * (value_comp.get_value() if value_comp != null else 1)
			return accum, 0)

func calculate_trade_score(items : Array[EMC_Item]) -> float:
	return calulate_item_score_generic(items, _item_preference)
