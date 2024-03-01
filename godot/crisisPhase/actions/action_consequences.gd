extends Node
class_name EMC_ActionConsequences

var _avatar: EMC_Avatar
var _inventory: EMC_Inventory
var _stage_mngr : EMC_StageMngr
var _lower_gui_node : Node
var _day_mngr : EMC_DayMngr

const AGATHE_EVENT : DialogueResource = preload("res://res/dialogue/agathe_event.dialogue")
const JULIA_EVENT : DialogueResource = preload("res://res/dialogue/julia_event.dialogue")
const GERHARD_EVENT : DialogueResource = preload("res://res/dialogue/gerhard_event.dialogue")
const PETRO_EVENT : DialogueResource = preload("res://res/dialogue/petro_event.dialogue")
const MERT_EVENT : DialogueResource = preload("res://res/dialogue/mert_event.dialogue")
const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")

########################################## PUBLIC METHODS ##########################################
func _init(p_avatar: EMC_Avatar, p_inventory: EMC_Inventory, p_stage_mngr : EMC_StageMngr, p_lower_gui_node : Node, p_day_mngr : EMC_DayMngr) -> void:
	_avatar = p_avatar
	_inventory = p_inventory
	_stage_mngr = p_stage_mngr
	_lower_gui_node = p_lower_gui_node
	_day_mngr = p_day_mngr

############################################ Avatar ################################################

func add_health(p_value: int) -> void:
	_avatar.add_health(p_value)

func add_happiness(p_value: int) -> void:
	_avatar.add_happinness(p_value)

############################################ Items #################################################

## Adds the [EMC_Item]
func add_item(p_ID: EMC_Item.IDs) -> void:
	_inventory.add_new_item(p_ID)

func add_item_by_name(p_name : String) -> void:
	_inventory.add_new_item(JsonMngr.name_to_id(p_name))

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
	var item := _inventory.get_item_of_ID(JsonMngr.name_to_id(p_name))
	if item == null:
		return
	
	var usesIC: EMC_IC_Uses = item.get_comp(EMC_IC_Uses)
	if usesIC != null:
		usesIC.use_item()
	if usesIC.no_uses_left():
		_inventory.remove_specific_item(item)

########################################## Dialogue ################################################

func trigger_dialogue(data : Dictionary) -> void:
	var dialog_res : DialogueResource

	var p_name : String = data.get("dialogue_name", "")
	var action_names : Array[String]
	action_names.assign(data.get("action_names"))
	var actions : Array[EMC_Action]
	for act_name in action_names:
		var action : EMC_Action = JsonMngr.name_to_action(act_name)
		actions.append(action)
		action.executed.connect(_day_mngr._on_action_executed)
	
	#for callding : Dictionary in action.executed.get_connections():
		#action.executed.disconnect(callding.get("callable"))
	
	var executer := EMC_ActionExecuter.new(actions)
	
	match p_name:
		"agathe_event":
			dialog_res = AGATHE_EVENT
		"julia_event":
			dialog_res = JULIA_EVENT
		"gerhard_event":
			dialog_res = GERHARD_EVENT
		"petro_event":
			dialog_res = PETRO_EVENT
		"mert_event":
			dialog_res = MERT_EVENT
	
	
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	_lower_gui_node.add_child(dialogue_GUI)
	dialogue_GUI.start(dialog_res, "START", [executer])
	_lower_gui_node.get_tree().paused = true

############################################ Stage #################################################

func change_stage(data : Dictionary) -> void:
	_stage_mngr.change_stage(data.get("stage_name"))
	_avatar.position = data.get("avatar_pos")
	_stage_mngr.respawn_NPCs(data.get("npc_pos"))

