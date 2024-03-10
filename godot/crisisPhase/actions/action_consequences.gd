extends Node
class_name EMC_ActionConsequences

const NO_PARAM: int = 0
const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _avatar: EMC_Avatar
var _inventory: EMC_Inventory
var _stage_mngr : EMC_StageMngr
var _lower_gui_node : Node
var _day_mngr : EMC_DayMngr
var _tooltip_GUI: EMC_TooltipGUI
var _opt_event_mngr: EMC_OptionalEventMngr
var _crisis_mngr: EMC_CrisisMngr

########################################## PUBLIC METHODS ##########################################
func _init(p_avatar: EMC_Avatar, p_inventory: EMC_Inventory, p_stage_mngr : EMC_StageMngr, \
p_lower_gui_node : Node, p_day_mngr : EMC_DayMngr, p_tooltip_GUI: EMC_TooltipGUI,
p_opt_event_mngr: EMC_OptionalEventMngr, p_crisis_mngr: EMC_CrisisMngr) -> void:
	_avatar = p_avatar
	_inventory = p_inventory
	_stage_mngr = p_stage_mngr
	_lower_gui_node = p_lower_gui_node
	_day_mngr = p_day_mngr
	_tooltip_GUI = p_tooltip_GUI
	_opt_event_mngr = p_opt_event_mngr
	_rng.randomize()

############################################ Avatar ################################################

func add_health(p_value: int) -> void:
	_avatar.add_health(p_value)


func add_happiness(p_value: int) -> void:
	_avatar.add_happiness(p_value)


############################################ Items #################################################

## Adds the [EMC_Item]
func add_item(p_ID: EMC_Item.IDs) -> void:
	if _inventory.add_new_item(p_ID) == false:
		_tooltip_GUI.open("Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!")


## Allows multiple items, separated through a semicolon
func add_items_by_name(p_names : String) -> void:
	for item_name in p_names.split(";"):
		if _inventory.add_new_item(JsonMngr.item_name_to_id(item_name)) == false:
			_tooltip_GUI.open("Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!")
			break


## Adds either Water depended on the Water-State
func add_tap_water(_dummy: int) -> void:
	match OverworldStatesMngr.get_water_state():
		OverworldStatesMngr.WaterState.CLEAN:
			_inventory.add_new_item(EMC_Item.IDs.WATER)
		OverworldStatesMngr.WaterState.DIRTY:
			_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
		OverworldStatesMngr.WaterState.NONE:
			printerr("Can't add water while there is no water available! \
				This should be checked in the constraints!")
		_: printerr("Unknown Water state!")


## Reduces the uses of the Uses-[EMC_ItemComponent] of the [EMC_Item]
## If it is completely used up, the item is removed from the [EMC_Inventory]
## TODO: inventory has a method for that now!!
## TODO: Improvement idea: change parameter type to string, and use JsonMngr.item_name_to_id
## This way, normal actions can be included in the JSON file
func use_item(p_ID: EMC_Item.IDs) -> void:
	var item := _inventory.get_item_of_ID(p_ID)
	if item == null:
		return
	
	var usesIC: EMC_IC_Uses = item.get_comp(EMC_IC_Uses)
	if usesIC != null:
		usesIC.use_item()
	if usesIC.no_uses_left():
		_inventory.remove_specific_item(item)


func use_item_by_name(p_name: String) -> void:
	var item := _inventory.get_item_of_ID(JsonMngr.item_name_to_id(p_name))
	if item == null:
		return
	
	var usesIC: EMC_IC_Uses = item.get_comp(EMC_IC_Uses)
	if usesIC != null:
		usesIC.use_item()
	if usesIC.no_uses_left():
		_inventory.remove_specific_item(item)


############################################ Other ################################################
func open_bbk_brochure(_dummy: int = NO_PARAM) -> void:
	EMC_Information.open_bbk_brochure()


func use_radio(_dummy: int = NO_PARAM) -> void:
	var radio_msg: String
	var active_events := _opt_event_mngr.get_active_events()
	if !active_events.is_empty():
		var chosen_event: EMC_OptionalEventMngr.Event = active_events.pick_random()
		radio_msg = chosen_event.descr
		_opt_event_mngr.set_event_as_known(chosen_event.name)
	else:
		#50-50 zwischen unnützem Text und Szenario Name
		if _rng.randi_range(0, 1) == 0:
			radio_msg = OverworldStatesMngr.get_notification()
		else:
			radio_msg = "Es läuft mal wieder viel zu laute Werbung..."
	_tooltip_GUI.open(radio_msg)


func fill_rainbarrel(_dummy: int = NO_PARAM) -> void:
	var _added_water_quantity : int = _rng.randi_range(1, 6) # in units of 250ml
	OverworldStatesMngr.set_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL, 
		min(OverworldStatesMngr.get_furniture_state_maximum(EMC_Upgrade.IDs.RAINWATER_BARREL), 
		(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) + _added_water_quantity)))

########################################## Dialogue ################################################

func trigger_dialogue(p_dialogue_name : String) -> void:
	var dialog_res : DialogueResource
	var executer := EMC_ActionExecuter.new(_day_mngr._on_action_executed)
	
	dialog_res = load("res://res/dialogue/" + p_dialogue_name + ".dialogue")
	
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	_lower_gui_node.add_child(dialogue_GUI)
	dialogue_GUI.start(dialog_res, "START", [executer])
	_lower_gui_node.get_tree().paused = true

############################################ Stage #################################################

func change_stage(p_data : Dictionary) -> void:
	_stage_mngr.change_stage(p_data.get("stage_name"))
	_avatar.position = p_data.get("avatar_pos")
	_stage_mngr.respawn_NPCs(p_data.get("npc_pos"))

############################################ JSON ##################################################

## This function converts Dictionarys conatining consequnces with posible Vector or other json incompatible
## Datatypes in to Dictionary with json compatible Datatype
static func to_json(data : Dictionary) -> Dictionary:
	var result : Dictionary = {}
	if data.has("change_stage"):
		result["change_stage"] = {
			"avatar_pos" : {
				"x" : data["change_stage"]["avatar_pos"].x,
				"y" : data["change_stage"]["avatar_pos"].y
			}
		}
		
		result["change_stage"]["npc_pos"] = {}
		
		for npc : String in data["change_stage"]["npc_pos"]:
			result["change_stage"]["npc_pos"][npc] = {
				"x" : data["change_stage"]["npc_pos"][npc].x,
				"y" : data["change_stage"]["npc_pos"][npc].y,
			}
	
	result.merge(data)
	
	return result

## This function converts consequnces in to using more compact json incompatible Datatypes (Vectors)
static func from_json(data : Dictionary) -> Dictionary:
	if data.has("change_stage"):
		var avatar_pos : Dictionary = data["change_stage"].get("avatar_pos", {})
		var x : int = avatar_pos.get("x", NAN)
		var y : int = avatar_pos.get("y", NAN)
		
		var npc_pos : Dictionary = data["change_stage"].get("npc_pos", {})
		
		for npc : String in npc_pos:
			npc_pos[npc] = Vector2(npc_pos[npc]["x"], npc_pos[npc]["y"])
			
		var tmp_data := {
			"avatar_pos": Vector2i(x, y),
			"npc_pos" : npc_pos,
		}
		tmp_data.merge(data["change_stage"])
		data["change_stage"] = tmp_data
	
	return data
	
