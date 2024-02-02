extends Node

const RECIPT_SOURCE := "res://res/JSONs/recipe.json"
const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")

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
			input_item_IDs.assign(input_item_names.map(func(name : String) -> EMC_Item.IDs : return EMC_Item.IDs.get(name.to_upper())))
		
		if input_item_IDs.is_empty():
			printerr("Recipe-JSON input_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
			
		if output_item_ID == EMC_Item.IDs.DUMMY:
			if EMC_Item.IDs.get(output_item_name) == null:
				printerr("Recip-JSON: no such item: " + output_item_name + " in Recipe Nr.: " + str(i))
			else:
				output_item_ID = EMC_Item.IDs.get(output_item_name)
				
		if output_item_ID == EMC_Item.IDs.DUMMY:
			printerr("Recipe-JSON output_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
		
		var needs_water : bool = recipe_json.get("needs_water", false) as bool
		var needs_heat : bool = recipe_json.get("needs_heat", false) as bool
		
		var new_recipe : EMC_Recipe = RECIPE_SCN.instantiate()
		new_recipe.setup(input_item_IDs, output_item_ID, needs_water, needs_heat)
		
		results.append(new_recipe)
		i += 1
	
	return results
