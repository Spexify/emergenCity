extends EMC_ActionGUI

const ITEM_SCN : PackedScene = preload("res://items/item.tscn")
const RECIPE_SCN: PackedScene = preload("res://GUI/recipe.tscn")
var _inventory: EMC_Inventory
var _last_clicked_recipe: EMC_Recipe
	
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory
	var recipe_list := $DecisionWindow/MarginContainer/VBC/RecipeBox/ScrollContainer/RecipeList
	# "Ravioli (warm)": [[3],[]]
	var ravioli_recipe := RECIPE_SCN.instantiate()
	var input_items : Array[EMC_Item.IDs]
	var input_items2 : Array[EMC_Item.IDs]
	input_items.append(EMC_Item.IDs.RAVIOLI_TIN)
	ravioli_recipe.setup(input_items, EMC_Item.IDs.RAVIOLI_MEAL, false, true)
	recipe_list.add_child(ravioli_recipe)
	ravioli_recipe.was_pressed.connect(_on_recipe_pressed)
	var cooked_pasta_recipe := RECIPE_SCN.instantiate()
	input_items2 = [EMC_Item.IDs.UNCOOKED_PASTA]
	cooked_pasta_recipe.setup(input_items2, EMC_Item.IDs.COOKED_PASTA, false, true)
	recipe_list.add_child(cooked_pasta_recipe)
	cooked_pasta_recipe.was_pressed.connect(_on_recipe_pressed)
	


func show_gui(p_action : EMC_Action) -> void:
	_action = p_action
	visible = true
	#var item_on_slot2 := _inventory.get_item_of_slot(2)
	#item_on_slot2.get_ID()
	#var component_food : EMC_IC_Food
	#for comp in item_on_slot2.get_comps():
		#if comp is EMC_IC_Food:
			#component_food = comp
	
	#$DecisionWindow/MarginContainer/VBC/RecipeBox/Description.text = \
		#str(component_food.get_formatted_values())
		
	
	# Enter code here if necessary 
	opened.emit()


func _on_cooking_pressed() -> void: 
	if _recipe_cookable(_last_clicked_recipe):
		_cook_recipe(_last_clicked_recipe)


func _on_cancel_pressed() -> void:
	visible = false
	# Global.goto_scene("res://crisisPhase/crisis_phase.tscn")


func _on_recipe_pressed(p_recipe: EMC_Recipe) -> void:
	_last_clicked_recipe = p_recipe
	var input_items_list := $DecisionWindow/MarginContainer/VBC/PanelContainer/HBC/ScrollContainer/InputItemList
	for unwanted_child : EMC_Item in input_items_list.get_children():
		input_items_list.remove_child(unwanted_child)
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		var item : EMC_Item = ITEM_SCN.instantiate()
		item.setup(input_item_ID)
		input_items_list.add_child(item)


## TODO: Also check on electricity etc.
func _recipe_cookable(p_recipe: EMC_Recipe) -> bool:
	return true


func _cook_recipe(p_recipe: EMC_Recipe) -> void:
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		_inventory.remove_item(input_item_ID)
	_inventory.add_new_item(p_recipe.get_output_item_ID())
