extends Node

const INVALID_INT_VALUE: int = 0
const INVALID_STRING_VALUE: String = "ERROR"
const INVALID_DICTIONARY_VALUE: Dictionary = {}

## RECIPTS
const RECIPT_SOURCE := "res://res/JSONs/recipe.json"
const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")
## ITEMS
const ITEM_SOURCE := "res://res/JSONs/item.json"
const ITEM_TRANSLATE_SOURCE := "res://res/JSONs/item_ids.json"
## POPUPS
const POP_UP_ACTION_SOURCE := "res://res/JSONs/pop_up_action.json"
## OPT-EVENTS
const OPT_EVENTS_SOURCE := "res://res/JSONs/optional_events.json"
## NPCS
const NPS_Source := "res://res/JSONs/npcs.json"
## BOOKS
const BOOKS_SOURCE := "res://res/JSONs/books.json"
## ACTIONS
const ACTION_SOURCE := "res://res/JSONs/action.json"
## DOORBELL
const DOORBELL_SOURCE := "res://res/JSONs/doorbell.json"
## SCENARIOS
const SCENARIOS_SOURCE := "res://res/JSONs/scenarios.json"
## UPGARDE
const UPGRADES_SOURCE := "res://res/JSONs/upgrades.json"

########################################JSON RECIPES################################################

func load_recipes() -> Array[EMC_Recipe]:
	if not FileAccess.file_exists(RECIPT_SOURCE):
		printerr("Could not load recipes from source: " + RECIPT_SOURCE)
		return []

	var recipe_source : FileAccess = FileAccess.open(RECIPT_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("JSON-Recipe Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return []
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of recipe json (" + RECIPT_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
		
	var results : Array[EMC_Recipe]
	
	var i : int = 0
	for recipe_json : Dictionary in data:
		var input_item_IDs : Array[EMC_Item.IDs] 
		input_item_IDs.assign(recipe_json.get("input_item_IDs", []))
		var output_item_ID : EMC_Item.IDs = recipe_json.get("output_item_ID", EMC_Item.IDs.DUMMY) as EMC_Item.IDs
		
		var input_item_names : Array[String]
		input_item_names.assign(recipe_json.get("input_item_names", []))
		var output_item_name : String = (recipe_json.get("output_item_name", "DUMMY") as String).to_upper()
		
		if input_item_IDs.is_empty():
			input_item_IDs.assign(input_item_names.map(func(name : String) -> EMC_Item.IDs : return item_name_to_id(name.to_upper())))
		
		if input_item_IDs.is_empty():
			printerr("Recipe-JSON input_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
			
		if output_item_ID == EMC_Item.IDs.DUMMY:
			if item_name_to_id(output_item_name) == null:
				printerr("Recip-JSON: no such item: " + output_item_name + " in Recipe Nr.: " + str(i))
			else:
				output_item_ID = item_name_to_id(output_item_name)
				
		if output_item_ID == EMC_Item.IDs.DUMMY:
			printerr("Recipe-JSON output_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
		
		var needs_water : bool = recipe_json.get("needs_water", false) as bool
		var needs_heat : bool = recipe_json.get("needs_heat", false) as bool
		
		var new_recipe : EMC_Recipe = RECIPE_SCN.instantiate()
		new_recipe.setup(input_item_IDs, output_item_ID, needs_water, needs_heat)
		
		results.append(new_recipe)
		i += 1
	
	return results

#########################################JSON ITEMS#################################################

var _is_items_loaded : bool = false
var _name_to_id : Dictionary = {}
var _id_to_item_vars : Dictionary = {}

#...................................Conversion Functions............................................

func get_item_vars_from_id(ID : int) -> Dictionary:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return {}
		
	if not _id_to_item_vars.has(str(ID)):
		printerr("Item with ID " + str(ID) + " cannot be found")
		return {}
		
	return _id_to_item_vars[str(ID)]

## Translates item name to its ID
## Better than using the enum, as it uses the actual JSON-translation file
func item_name_to_id(p_name : String) -> int:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return 0
	
	if not _name_to_id.has(p_name):
		printerr("Item with name " + p_name + " cannot be found")
		return 0
	
	return _name_to_id[p_name]


func item_id_to_name(ID : int) -> String:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return "DUMMY"
		
	return _name_to_id.find_key(ID)
	
func get_all_ids() -> Array[int]:
	var result : Array[int]
	result.assign(_name_to_id.values())
	return result
	
func get_all_names() -> Array[String]:
	var result : Array[String]
	result.assign(_name_to_id.keys())
	return result

#...................................JSON load Functions.............................................

func load_item_translator() -> void:
	if not FileAccess.file_exists(ITEM_TRANSLATE_SOURCE):
		printerr("Could not load item translatore from source: " + ITEM_TRANSLATE_SOURCE)
		return

	var recipe_source : FileAccess = FileAccess.open(ITEM_TRANSLATE_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Item-Translator-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
		
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_DICTIONARY:
		printerr("Invalid format of Item-Translator-JSON (" + ITEM_TRANSLATE_SOURCE + "). Make sure it is in form of a Dictonarie.")
		
	_name_to_id = data


func load_items() -> void:
	load_item_translator()
	
	if not FileAccess.file_exists(ITEM_SOURCE):
		printerr("Could not load recipes from source: " + ITEM_SOURCE)
		return

	var recipe_source : FileAccess = FileAccess.open(ITEM_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Item-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Item-JSON (" + ITEM_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
		
	#_name_to_id = {}
	_id_to_item_vars = {}
	
	var item_index : int = 0
	
	for item : Dictionary in data:
		var item_data : Dictionary = {}
		
		var _id : Variant = item.get("ID", NAN)
		if typeof(_id) != TYPE_FLOAT or _id == NAN or _name_to_id.find_key(_id) == null:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'ID'.")
			item_index += 1
			continue
		
		var _name : Variant = item.get("name", INVALID_STRING_VALUE)
		if typeof(_name) != TYPE_STRING or _name == INVALID_STRING_VALUE:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'name'.")
			item_index += 1
			continue
		
		var _descr : String = item.get("descr", INVALID_STRING_VALUE)
		if typeof(_descr) != TYPE_STRING or _descr == INVALID_STRING_VALUE:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'descr'.")
			item_index += 1
			continue
			
		var _sound : Dictionary = item.get("sound", INVALID_DICTIONARY_VALUE)
		if typeof(_sound) != TYPE_DICTIONARY:
			printerr("Item-JSON: item in position " + str(item_index) + " has no or an invalid item 'sound'.")
		else:
			item_data["sound"] = _sound
			
		var _comp_dicts : Variant = item.get("comps", [])
		if typeof(_comp_dicts) != TYPE_ARRAY:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'comps'.")
			item_index += 1
			continue
		
		item_data = {
			"name": _name,
			"descr": _descr,
			"comps": _comp_dicts,
			#"sound": _sound,
		}
		
		_id_to_item_vars[str(_id)] = item_data
		
		item_index += 1
	
	_is_items_loaded = true

######################################JSON POPUP-EVENTS#############################################

var _pop_up_actions : Array[EMC_PopUpAction]
var _pop_up_name_to_id : Dictionary
var _is_pop_ups_loaded : bool = false

func name_to_pop_up_action(p_name : String) -> EMC_PopUpAction:
	if not _is_pop_ups_loaded:
		printerr("PopUp Actions not loaded")
		return null
	for pop in _pop_up_actions:
		if p_name == pop.get_ACTION_NAME():
			return pop
			
	assert(false)
	return null


## CAUTION: Because the same array is used there is a risk, that a reference is manipulated during runtime
## which could lead to unexpected behaviour! Ideally the filtered entry should be duplicated!!!
func get_pop_up_action(action_constraint : EMC_ActionConstraints) -> EMC_PopUpAction:
	var filtered : Array[EMC_PopUpAction] = _pop_up_actions.filter(func (action : EMC_PopUpAction) -> bool: 
		for key : String in action.get_constraints_prior():
			var params : Variant = action.get_constraints_prior()[key]
			
			## TODO: Handle non exisitend functions
			if not Callable(action_constraint, key).call(params) == EMC_ActionConstraints.NO_REJECTION:
				return false
		return true
		)
	
	#for popupevent in filtered: #TEST
		#if popupevent.get_ACTION_NAME() == "MERT_KNOCKS": #TEST
			#return popupevent #TEST
	return filtered.pick_random()


func load_pop_up_actions() -> void:
	if not FileAccess.file_exists(POP_UP_ACTION_SOURCE):
		printerr("Could not load PopUps from source: " + POP_UP_ACTION_SOURCE)
		return

	var recipe_source : FileAccess = FileAccess.open(POP_UP_ACTION_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("PopUp-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Popup Events-JSON (" + POP_UP_ACTION_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
	
	var pop_up_id : int = 1000 
	
	for pop_up : Dictionary in data:
		var _name :String = pop_up.get("name")
		
		var pop_up_data : Dictionary = {
			"id": pop_up_id,
			"name": _name,
		}
		
		for key : String in pop_up:
			if key != "name":
				pop_up_data[key] = pop_up[key]
		
		_pop_up_name_to_id[str(pop_up_id)] = _name
		_pop_up_actions.append(EMC_PopUpAction.from_dict(pop_up_data))
		
		pop_up_id += 1
	
	_is_pop_ups_loaded = true


######################################JSON OPT EVENTS#############################################
var _opt_events : Array[EMC_OptionalEventMngr.Event]
#var _pop_up_name_to_id : Dictionary
var _is_opt_events_loaded : bool = false

func load_opt_events() -> void:
	if not FileAccess.file_exists(OPT_EVENTS_SOURCE):
		printerr("Could not load PopUps from source: " + OPT_EVENTS_SOURCE)
		return

	var opt_events_source : FileAccess = FileAccess.open(OPT_EVENTS_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = opt_events_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Opt-Events JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Optional Events-JSON (" + OPT_EVENTS_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
	
	#General structure of JSON fine, let's loop over all the entries
	for opt_event_data : Dictionary in data:
		var _name: String = opt_event_data.get("name")
		var probability: int = opt_event_data.get("probability")
		var descr: String = opt_event_data.get("descr")
		var announce_only_on_radio: bool = opt_event_data.get("announce_only_on_radio")
		var active_periods: int = opt_event_data.get("active_periods")
		var constraints: Dictionary = opt_event_data.get("constraints")
		var consequences: Dictionary = opt_event_data.get("consequences")
		var stage_name: String = opt_event_data.get("stage_name", "error").to_lower()
		
		#Dynamic tiles spawns
		var dynamic_tiles_dict : Array[Dictionary]
		dynamic_tiles_dict.assign(opt_event_data.get("spawn_tiles", []))
		var spawn_tiles: Array[EMC_OptionalEventMngr.SpawnTiles] = []
		
		for entry in dynamic_tiles_dict:
			var new_dynamic_tiles := EMC_OptionalEventMngr.SpawnTiles.new()
			new_dynamic_tiles.tilemap_pos = Vector2i(entry.get("tilemap_x_pos", -1),
		 											 entry.get("tilemap_y_pos", -1))
			new_dynamic_tiles.atlas_coord = Vector2i(entry.get("atlas_x_coord", -1),
													 entry.get("atlas_y_coord", -1))
			new_dynamic_tiles.tiles_cols = entry.get("tiles_cols", -1)
			new_dynamic_tiles.tiles_rows = entry.get("tiles_rows", -1)
			new_dynamic_tiles.overwrite_existing_tiles = entry.get("overwrite_existing_tiles", false)
			
			spawn_tiles.append(new_dynamic_tiles)
		
		##Dynamic NPCs spawns
		var spawn_NPCs_dict : Array[Dictionary]
		spawn_NPCs_dict.assign(opt_event_data.get("spawn_NPCs", []))
		var spawn_NPCs: Array[EMC_OptionalEventMngr.SpawnNPCs] = []
		
		for spawn_NPC_dict_entry in spawn_NPCs_dict:
			var new_NPC_spawn := EMC_OptionalEventMngr.SpawnNPCs.new()
			new_NPC_spawn.NPC_name = spawn_NPC_dict_entry.get("NPC_name", "error") #NOT TO LOWER!
			new_NPC_spawn.pos = Vector2(spawn_NPC_dict_entry.get("x_pos", -1), \
										spawn_NPC_dict_entry.get("y_pos", -1))
			
			spawn_NPCs.append(new_NPC_spawn)
		
		
		## Create new optional event
		var opt_event: EMC_OptionalEventMngr.Event = \
			EMC_OptionalEventMngr.Event.new(_name, probability, descr, announce_only_on_radio, \
				active_periods, constraints, consequences, stage_name, spawn_NPCs, spawn_tiles)
		_opt_events.append(opt_event)
	
	_is_opt_events_loaded = true


## CAUTION: Because the same array is used there is a risk, that a reference is manipulated during runtime
## which could lead to unexpected behaviour! Ideally the filtered entry should be duplicated!!!
func get_possible_opt_events(p_action_constraint : EMC_ActionConstraints) -> Array[EMC_OptionalEventMngr.Event]:
	var filtered : Array[EMC_OptionalEventMngr.Event] = _opt_events.filter(func (opt_event: EMC_OptionalEventMngr.Event) -> bool: 
		for key : String in opt_event.constraints:
			var params : Variant = opt_event.constraints[key]
			
			## TODO: Handle non exisitend functions
			if not Callable(p_action_constraint, key).call(params) == EMC_ActionConstraints.NO_REJECTION:
				return false
		return true
		)
	
	##TODO: Also check, that the location at which NPCs are spawned isn't already used in a currently
	## active opt. event (otherhwise the events would collide!)
	
	return filtered

########################################JSON ACTION#################################################

var _actions : Dictionary
var _is_action_loaded : bool = false
var ACTION_SCNS : Dictionary = {} 

const DEFAULT_ACTION_STR = "action" 
const ACTION_SCN_PATH = "res://crisisPhase/actions/"

func name_to_action_id(p_name : String) -> int:
	if not _is_action_loaded:
		printerr("Actions not loaded")
		return NAN
	for key : int in _actions.keys():
		if _actions[key].get_ACTION_NAME() == p_name:
			return key
	return NAN


func name_to_action(p_name : String) -> EMC_Action:
	if not _is_action_loaded:
		printerr("Actions not loaded")
		return null
	return _actions.get(name_to_action_id(p_name))


func id_to_action(id : int) -> EMC_Action:
	if not _is_action_loaded:
		printerr("Actions not loaded")
		return null
	return _actions.get(id)


func load_actions() -> void:
	if not FileAccess.file_exists(ACTION_SOURCE):
			printerr("Could not load PopUps from source: " + ACTION_SOURCE)
			return

	var recipe_source : FileAccess = FileAccess.open(ACTION_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Action-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Item-JSON (" + ITEM_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
	
	var act_index : int = 0
	for act : Dictionary in data:
		var _type : String = act.get("type", INVALID_STRING_VALUE)
		if _type == INVALID_STRING_VALUE:
			printerr("Action-JSON: Action in position: " + str(act_index)+ " has not type declared. (Skipped)")
			continue
		_type = _type.to_lower()
		
		var _action_id : int = act.get("id", NAN)
		if _action_id == NAN:
			printerr("Action-JSON: Action in position: " + str(act_index)+ " has not action_id declared. (Skipped)")
			continue
		
		var _consequences : Dictionary = act.get("consequences", INVALID_DICTIONARY_VALUE)
		if _consequences != INVALID_DICTIONARY_VALUE:
			if _consequences.has("change_stage"):
				var avatar_pos : Dictionary = _consequences["change_stage"].get("avatar_pos", INVALID_DICTIONARY_VALUE)
				if avatar_pos == INVALID_DICTIONARY_VALUE:
					printerr("Action-JSON: Action in position: " + str(act_index)+ " has invalid parameters for consequence 'change_stage'. (Skipped)")
					continue
				var x : int = avatar_pos.get("x", NAN)
				if x == NAN:
					printerr("Action-JSON: Action in position: " + str(act_index)+ " has invalid parameters for consequence 'change_stage'. (Skipped)")
					continue
				var y : int = avatar_pos.get("y", NAN)
				if y == NAN:
					printerr("Action-JSON: Action in position: " + str(act_index)+ " has invalid parameters for consequence 'change_stage'. (Skipped)")
					continue
				
				var npc_pos : Dictionary = _consequences["change_stage"].get("npc_pos", {})
				
				for npc : String in npc_pos:
					npc_pos[npc] = Vector2(npc_pos[npc]["x"], npc_pos[npc]["y"])
					
				var tmp_data := {
					"avatar_pos": Vector2i(x, y),
					"npc_pos" : npc_pos,
				}
				tmp_data.merge(_consequences["change_stage"])
				_consequences["change_stage"] = tmp_data
		
		var action_data : Dictionary = {
			"id": _action_id,
			"type": _type,
		}
		
		action_data.merge(act)
				
		var act_scn : Resource = ACTION_SCNS.get(_type, null)
			
		if act_scn == null:
			if _type == DEFAULT_ACTION_STR:
				act_scn = load(ACTION_SCN_PATH + "action.gd")
			else:
				act_scn = load(ACTION_SCN_PATH + _type + "_action.gd")
			
			if act_scn == null:
				printerr("Action-JSON: Action in position: " + str(act_index) + " has an invalid Action-Type: " + _type)
				assert(act_scn != null)
			
			ACTION_SCNS[_type] = act_scn

		_actions[_action_id] = act_scn.from_dict(action_data)
	
		act_index += 1
	_is_action_loaded = true


##########################################DOOR BELL#################################################

func load_door_bell() -> Dictionary:
	if not FileAccess.file_exists(DOORBELL_SOURCE):
		printerr("Could not load doorbell from source: " + DOORBELL_SOURCE)
		return {}

	var bell_source : FileAccess = FileAccess.open(DOORBELL_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = bell_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("DoorBell-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
		
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_DICTIONARY:
		printerr("Invalid format of DoorBell-JSON (" + DOORBELL_SOURCE + "). Make sure it is in form of a Dictonary.")
		
	return data as Dictionary

##########################################JSON NPCS#################################################

const _NPC_SCN: PackedScene = preload("res://crisisPhase/characters/NPC.tscn")

func load_NPC() -> Array[EMC_NPC]:
	assert(_is_items_loaded, "NPS-JSON: Items must be loaded before NPCs")
	
	if not FileAccess.file_exists(NPS_Source):
		printerr("Could not load PopUps from source: " + NPS_Source)
		return []

	var recipe_source : FileAccess = FileAccess.open(NPS_Source, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("PopUp-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return []
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of NPC-JSON (" + NPS_Source + "). Make sure it is in form of an Array of Dictonaries.")
		
	var result : Array[EMC_NPC]
	
	var i : int = 0 
	for dict_data : Dictionary in data:
		var p_name : String = dict_data.get("name", "ERROR") 
		assert(p_name != "ERROR", "NPC-JSON: NPC in position: " + str(i) + " has no name or an invalide name(such as 'ERROR').")
		var t_pitch : float = dict_data.get("pitch", 0.0)
		assert(t_pitch != 0.0, "NPC-JSON: NPC in position: " + str(i) + " has no pitch or an invalide pitch(such as 0.0).")
		
		var npc := _NPC_SCN.instantiate()
		npc.setup(p_name)
		npc._dialogue_pitch = t_pitch
		
		var p_trades : Variant = dict_data.get("trade", false)
		if typeof(p_trades) != TYPE_BOOL:
			assert(typeof(p_trades) == TYPE_DICTIONARY, "NPC-JSON: NPC in position: " + str(i) + " has invalide trades format.")
			var trade : EMC_TradeMngr.TradeBid = EMC_TradeMngr.deserialize_tradebid(p_trades)
			npc.set_trade_bid(trade)
		
		result.append(npc)
		i += 1
	return result

########################################JSON RECIPES################################################

func load_books() -> Array[EMC_BookGUI.Book]:
	if not FileAccess.file_exists(BOOKS_SOURCE):
		printerr("Could not load books from source: " + BOOKS_SOURCE)
		return []
	
	var books_src : FileAccess = FileAccess.open(BOOKS_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	var json_string : String = books_src.get_as_text()
	var parse_result : Error = json.parse(books_src.get_as_text())
	if not parse_result == OK:
		printerr("PopUp-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return []
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of NPC-JSON (" + NPS_Source + "). Make sure it is in form of an Array of Dictonaries.")
		
	var result : Array[EMC_BookGUI.Book]
	
	var i : int = 0 
	for dict_data : Dictionary in data:
		var ID : int = dict_data.get("ID", INVALID_INT_VALUE) 
		assert(ID != INVALID_INT_VALUE, "BOOK-JSON: BOOK in position: " + str(i) + \
			" has no ID or an invalid value(such as " + str(INVALID_INT_VALUE) + ").")
		var title: String = dict_data.get("title", INVALID_STRING_VALUE)
		assert(title != INVALID_STRING_VALUE, "BOOK-JSON: BOOK in position: " + str(i) + \
			 " has no title or an invalide value('" + INVALID_STRING_VALUE + "').")
		
		var content: Array[String]
		var content_dicts : Array[Dictionary]
		content.assign(dict_data.get("content", []))
		
		result.append(EMC_BookGUI.Book.new(ID, title, content))
		i += 1
	return result

######################################JSON SCENARIOS################################################

func load_scenarios() -> Dictionary:
	if not FileAccess.file_exists(SCENARIOS_SOURCE):
			printerr("Could not load PopUps from source: " + SCENARIOS_SOURCE)
			return {}

	var recipe_source : FileAccess = FileAccess.open(SCENARIOS_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Action-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}

	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_DICTIONARY:
		printerr("Invalid format of Scenarios-JSON (" + SCENARIOS_SOURCE + "). Make sure it is in form of an Dictonarie.")
	
	return data

######################################JSON UPGRADES#################################################

var _is_upgrades_loaded : bool = false
var _id_to_upgrade_data : Dictionary = {}

func id_to_upgrade_data(id : int) -> Dictionary:
	if _is_upgrades_loaded:
		return _id_to_upgrade_data.get(id, {})
	printerr("Upgrades not yet loaded!")
	return {}

func load_upgardes() -> void:
	var data : Array = load_file_check_type(UPGRADES_SOURCE, "Upgrade", TYPE_ARRAY)
	
	if data == null:
		return
	
	for dict : Dictionary in data:
		if not (dict.has("id") and dict.has("display_name") and dict.has("description") and dict.has("price")
						and dict.has("state") and dict.has("state_maximum") and dict.has("tilemap_position")):
			printerr("Upgrade-JSON: there is at least one missing entry.")
			continue
		
		var id : int = dict["id"]
		dict.erase("id")
		
		_id_to_upgrade_data[id] = dict
		
		_id_to_upgrade_data[id]["tilemap_position"] = dict_to_vector(dict["tilemap_position"], TYPE_VECTOR2I)
		if _id_to_upgrade_data[id]["tilemap_position"] == null:
			continue
		
		if _id_to_upgrade_data[id].has("spawn_pos"):
			_id_to_upgrade_data[id]["spawn_pos"] = dict_to_vector(dict["spawn_pos"], TYPE_VECTOR2I)
			if _id_to_upgrade_data[id]["spawn_pos"] == null:
				continue
			
	_is_upgrades_loaded = true

func load_file_check_type(source : String, descr : String, type : Variant.Type) -> Variant:
	if not FileAccess.file_exists(source):
		push_error("Could not load " + descr + " from source: " + source)
		return null

	var recipe_source : FileAccess = FileAccess.open(source, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		push_error(descr + "-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null

	var data : Variant = json.get_data()
	
	if not typeof(data) == type:
		push_error("Invalid format of " + descr + "-JSON (" + source + "). Make sure it is in the type of " + str(type))
		return null
	
	return data 

func dict_to_vector(data : Dictionary, type : Variant.Type) -> Variant:
	var x : Variant = data.get("x", NAN)
	var y : Variant = data.get("y", NAN)
	var z : Variant = data.get("z", NAN)
	var w : Variant = data.get("w", NAN)
	
	match type:
		TYPE_VECTOR2:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2(x as float, y as float)
		TYPE_VECTOR2I:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2i(x as int, y as int)
		TYPE_VECTOR3:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3(x as float, y as float, z as float)
		TYPE_VECTOR3I:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3i(x as int, y as int, z as int)
		TYPE_VECTOR4:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4(x as float, y as float, z as float, w as float)
		TYPE_VECTOR4I:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4i(x as int, y as int, z as int, w as int)
		_: 
			push_error(str(type) + " is not a Type.")
	push_error("Wrong Type!")
	return null




















