extends Node
class_name EMC_TradeMngr
## TradeMngr has to be global, because the dialogue-system can only access global class's members
## TODO: Refactor idea: Remove TradeBids from NPC-JSON (and in NPC class), and just setup the 
## bid-items directly through the "setup_next_trade" function, one String parameter for input items,
## one for output items (multiple item names separated by semicolon).
## This allows for cleaner code, no dependency to the stage mngr/NPC classes and also more dynamic
## trade options, as you can directly choose what to offer in the dialogue. (For example if you have
## a "flea market" optional event where special trades, then special trades could be possible.)

class TradeBid:
	var sought_items: Array[int]  #from perspective of NPC
	var offered_items: Array[int] #from perspective of NPC


enum TradeFeasibility{
	FEASABLE = 0,
	UNFEASABLE = 1,
	NO_INVENTORY_SPACE = 2,
	MISSING_SOUGHT_ITEMS = 3,
	#Idea: Bad relationship with NPC
}

const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")

var _stage_mngr: EMC_StageMngr
var _inventory: EMC_Inventory
var _trade_feasibility: TradeFeasibility = TradeFeasibility.UNFEASABLE
var _curr_NPC: EMC_NPC


########################################## PUBLIC METHODS ##########################################
func setup(p_stage_mngr: EMC_StageMngr, p_inventory: EMC_Inventory) -> void:
	_stage_mngr = p_stage_mngr
	_inventory = p_inventory


## Before you access any of the other methods inside a dialogue, you first have to setup 
## this class with the [param p_NPC_name]
func setup_next_trade(p_NPC_name: String = "") -> void:
	if p_NPC_name == "":
		_trade_feasibility = TradeFeasibility.UNFEASABLE
		_curr_NPC = null
		return
	
	_curr_NPC = _stage_mngr.get_NPC(p_NPC_name)
	update_feasibility()


func update_feasibility() -> void:
	#Check sought items
	if !_has_sought_items():
		_trade_feasibility = TradeFeasibility.MISSING_SOUGHT_ITEMS
		return
	
	#Check space in the inventory
	if !_has_enough_inventory_space():
		_trade_feasibility = TradeFeasibility.NO_INVENTORY_SPACE
		return
	
	#If we reach this code line, we're good to go
	_trade_feasibility = TradeFeasibility.FEASABLE


func execute_trade() -> void:
	for sought_item_ID: EMC_Item.IDs in _get_sought_item_IDs():
		_inventory.remove_item(sought_item_ID)
	for offered_item_ID: EMC_Item.IDs in _get_offered_item_IDs():
		_inventory.add_new_item(offered_item_ID)
	
	update_feasibility()


func get_sought_items_text() -> String:
	var result: String = ""
	#First count them:
	var counted_items := _count_items(_get_sought_item_IDs())
	
	#Then create the string
	for sought_item_ID: EMC_Item.IDs in counted_items.keys():
		var sought_item := _ITEM_SCN.instantiate()
		sought_item.setup(sought_item_ID)
		var cnt: int = counted_items[sought_item_ID]
		
		result = result + str(cnt) + "x " + sought_item.get_name() + ", "
	
	#Remove superfluous comma:
	if result.length() > 0:
		result = result.left(result.length() - 2)
	
	return result


func get_offered_items_text() -> String:
	var result: String = ""
	#First count them:
	var counted_items := _count_items(_get_offered_item_IDs())
	
	for offered_item_ID: EMC_Item.IDs in counted_items.keys():
		var offered_item := _ITEM_SCN.instantiate()
		offered_item.setup(offered_item_ID)
		var cnt: int = counted_items[offered_item_ID]
		
		result = result + str(cnt) + "x " + offered_item.get_name() + ", "
	#Remove superfluous comma:
	if result.length() > 0:
		result = result.left(result.length() - 2)
	
	return result


func get_trade_feasibility() -> TradeFeasibility:
	return _trade_feasibility


func is_trade_feasible() -> bool:
	return _trade_feasibility == TradeFeasibility.FEASABLE


func get_unfeasibility_reason() -> String:
	match _trade_feasibility:
		TradeFeasibility.FEASABLE: #shouldn't happen
			return tr("TRD_FEAS")
		TradeFeasibility.UNFEASABLE: #shouldn't happen
			return tr("TRD_UNFEAS" )
		TradeFeasibility.NO_INVENTORY_SPACE:
			return tr("TRD_NO_SPACE")
		TradeFeasibility.MISSING_SOUGHT_ITEMS:
			return tr("TRD_NO_ITEMS")
		_:
			printerr("Unknown feasibility reason")
			return ""

static func deserialize_tradebid(data : Dictionary) -> EMC_TradeMngr.TradeBid:
	var sought_items : Array[String]
	var t_items : Variant = data.get("in")
	assert(typeof(t_items) == TYPE_ARRAY and typeof(t_items[0]) == TYPE_STRING, "Error: deserialize trades failed, no items or wrong format for 'in' Items.")
	sought_items.assign(t_items)
	
	var offered_items : Array[String]
	t_items = data.get("out")
	assert(typeof(t_items) == TYPE_ARRAY and typeof(t_items[0]) == TYPE_STRING, "Error: deserialize trades failed, no items or wrong format for 'out' Items.")
	offered_items.assign(t_items)
	
	var bid := EMC_TradeMngr.TradeBid.new()
	bid.sought_items.assign(sought_items.map(func (name : String) -> int: return JsonMngr.item_name_to_id(name)))
	bid.offered_items.assign(offered_items.map(func (name : String) -> int: return JsonMngr.item_name_to_id(name)))
	return bid

########################################## PRIVATE METHODS #########################################
func _get_sought_item_IDs() -> Array[int]:
	if _curr_NPC != null:
		var _trade_bid: EMC_TradeMngr.TradeBid = _curr_NPC.get_trade_bid()
		if _trade_bid != null:
			return _trade_bid.sought_items
	
	return []


func _get_offered_item_IDs() -> Array[int]:
	if _curr_NPC != null:
		var _trade_bid: EMC_TradeMngr.TradeBid = _curr_NPC.get_trade_bid()
		if _trade_bid != null:
			return _trade_bid.offered_items
	
	return []


func _has_sought_items() -> bool:
	var counted_items := _count_items(_get_sought_item_IDs())
	
	#Check if enough items of each type
	for counted_item_ID: EMC_Item.IDs in counted_items.keys():
		if _inventory.get_item_count_of_ID(counted_item_ID) < counted_items[counted_item_ID]:
			return false
	return true


## Determine the difference in needed inventory slots, and check if enough are
## available
func _has_enough_inventory_space() -> bool:
	var diff: int = 0
	for sought_item_ID: EMC_Item.IDs in _get_sought_item_IDs():
		diff -= 1
	for offered_item_ID: EMC_Item.IDs in _get_offered_item_IDs():
		diff += 1
	
	if diff <= 0:
		return true
	else:
		return _inventory.get_free_slot_cnt() >= diff


func _count_items(p_item_IDs: Array[int]) -> Dictionary:
	var counting_dict: Dictionary = {}
	#Count the sought items in a dictionary
	for item_ID: EMC_Item.IDs in p_item_IDs:
		if counting_dict.has(item_ID):
			counting_dict[item_ID] += 1 
		else:
			counting_dict[item_ID] = 1
	
	return counting_dict
