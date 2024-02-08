extends Node

const RECIPT_SOURCE := "res://res/JSONs/recipe.json"
const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")

const ITEM_SOURCE := "res://res/JSONs/item.json"
const ITEM_TRANSLATE_SOURCE := "res://res/JSONs/item_ids.json"

const POP_UP_ACTION_SOURCE := "res://res/JSONs/pop_up_action.json"

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
			input_item_IDs.assign(input_item_names.map(func(name : String) -> EMC_Item.IDs : return name_to_id(name.to_upper())))
		
		if input_item_IDs.is_empty():
			printerr("Recipe-JSON input_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
			
		if output_item_ID == EMC_Item.IDs.DUMMY:
			if name_to_id(output_item_name) == null:
				printerr("Recip-JSON: no such item: " + output_item_name + " in Recipe Nr.: " + str(i))
			else:
				output_item_ID = name_to_id(output_item_name)
				
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
	
func name_to_id(p_name : String) -> int:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return 0
	
	if not _name_to_id.has(p_name):
		printerr("Item with name " + p_name + " cannot be found")
		return 0
	
	return _name_to_id[p_name]
	
func id_to_name(ID : int) -> String:
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
		var _id : int = item.get("ID", 0)
		var _name : String = item.get("name", "DUMMY")
		var _descr : String = item.get("descr", "Error. This item is not supposed to appeare")
		var _comp_dicts : Array[Dictionary]
		_comp_dicts.assign(item.get("comps", []))
		
		var COMP_SCNS : Dictionary = {} 
		var _comps : Array[EMC_ItemComponent] = []
		
		var comp_index : int = 0
		
		for comp_dict in _comp_dicts:
			var comp_name : String = comp_dict.get("name", "error").to_lower()
			var comp_params : Variant = comp_dict.get("params", null)
			
			if comp_params == null: 
				printerr("Item-JSON: Item in position: " + str(item_index) + 
				 " has invalid parameters for the component "+ str(comp_name) +" at position: " + str(comp_index))
				assert(comp_params != null)
			
			var comp_scn : Resource = COMP_SCNS.get(comp_name, null)
			
			if comp_scn != null:
				_comps.append(comp_scn.new(comp_params))
			else:
				var tmp_scn : Resource = load("res://items/components/IC_" + comp_name + ".gd")
				
				if tmp_scn == null:
					printerr("Item-JSON: Item in position: " + str(item_index) + 
				 " has an invalid component. Name: " + comp_name +  " Nr.:" + str(comp_index))
					assert(tmp_scn != null)
				
				COMP_SCNS[comp_name] = tmp_scn
				_comps.append(COMP_SCNS[comp_name].new(comp_params))
				
			comp_index += 1
		
		var item_data : Dictionary = {
			"name": _name,
			"descr": _descr,
			"comps": _comps
		}
		
		#_name_to_id[_name] = _id
		_id_to_item_vars[str(_id)] = item_data
		
	item_index += 1
	
	_is_items_loaded = true

######################################JSON POPUP-EVENTS#############################################

var _pop_up_actions : Array[EMC_PopUpAction]
var _pop_up_name_to_id : Dictionary
var _is_pop_ups_loaded : bool = false

func get_pop_up_action(action_constraint : EMC_ActionConstraints) -> EMC_PopUpAction:
	var filtered : Array[EMC_PopUpAction] = _pop_up_actions.filter(func (action : EMC_PopUpAction) -> bool: 
		for key : String in action.get_constraints_prior():
			var params : Variant = action.get_constraints_prior()[key]
			if not Callable(action_constraint, key).call(params) == EMC_ActionConstraints.NO_REJECTION:
				return false
		return true
		)
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
		printerr("Invalid format of Item-JSON (" + ITEM_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")

	
	var pop_up_id : int = 1000 
	
	for pop_up : Dictionary in data:
		var _name :String = pop_up.get("name")
		
		var pop_up_data : Dictionary = {
			"ID": pop_up_id,
			"name": _name,
		}
		
		for key : String in pop_up:
			if key != "name":
				pop_up_data[key] = pop_up[key]
		
		_pop_up_name_to_id[str(pop_up_id)] = _name
		_pop_up_actions.append(EMC_PopUpAction.from_dict(pop_up_data))
		
	pop_up_id += 1
	
	_is_pop_ups_loaded = true
