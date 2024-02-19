extends EMC_ActionGUI

const ITEM_SCN : PackedScene = preload("res://items/item.tscn")
const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")
var _inventory: EMC_Inventory
var _last_clicked_recipe: EMC_Recipe
@onready var _recipe_list := $PanelContainer/MarginContainer/VBC/RecipeBox/ScrollContainer/RecipeList


func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory

	for recipe in JsonMngr.load_recipes():
		_recipe_list.add_child(recipe)
		recipe.was_pressed.connect(_on_recipe_pressed)
	


func show_gui(p_action : EMC_Action) -> void:
	_action = p_action
	for recipe in _recipe_list.get_children():
		if not _recipe_cookable(recipe):
			recipe.hide()
	visible = true
	#var item_on_slot2 := _inventory.get_item_of_slot(2)
	#item_on_slot2.get_ID()
	#var component_food : EMC_IC_Food
	#for comp in item_on_slot2.get_comps():
		#if comp is EMC_IC_Food:
			#component_food = comp
	
	#$PanelContainer/MarginContainer/VBC/RecipeBox/Description.text = \
		#str(component_food.get_formatted_values())
		
	
	# Enter code here if necessary 
	opened.emit()


func _on_cooking_pressed() -> void: 
	if _recipe_cookable(_last_clicked_recipe):
		_cook_recipe()


func _on_cancel_pressed() -> void:
	visible = false
	# Global.goto_scene("res://crisisPhase/crisis_phase.tscn")


func _on_recipe_pressed(p_recipe: EMC_Recipe) -> void:
	_last_clicked_recipe = p_recipe
	var input_items_list := $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/ScrollContainer/InputItemList
	for unwanted_child : EMC_Item in input_items_list.get_children():
		input_items_list.remove_child(unwanted_child)
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		var item : EMC_Item = ITEM_SCN.instantiate()
		item.setup(input_item_ID)
		input_items_list.add_child(item)


## TODO: Also check on electricity etc.
func _recipe_cookable(p_recipe: EMC_Recipe) -> bool:
	if p_recipe == null:
		return false
	var counting_dict: Dictionary = {}
	for input_item_ID: EMC_Item.IDs in p_recipe.get_input_item_IDs():
		if counting_dict.has(input_item_ID):
			counting_dict[input_item_ID] += 1 
		else:
			counting_dict[input_item_ID] = 1 
	for counted_item_ID: EMC_Item.IDs in counting_dict.keys():
		if _inventory.get_item_count_of_ID(counted_item_ID) < counting_dict[counted_item_ID]:
			return false
	return true


func _cook_recipe() -> void:
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		_inventory.remove_item(input_item_ID)
	_inventory.add_new_item(_last_clicked_recipe.get_output_item_ID())
	visible = false
	_action.executed.emit(_action)
