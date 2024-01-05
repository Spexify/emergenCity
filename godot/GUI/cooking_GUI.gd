extends EMC_ActionGUI

const RECIPE_SCN: PackedScene = preload("res://GUI/recipe.tscn")
var _inventory: EMC_Inventory
	
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory
	var recipe_list := $DecisionWindow/MarginContainer/VBC/RecipeBox/ScrollContainer/RecipeList
	# "Ravioli (warm)": [[3],[]]
	var ravioli_recipe := RECIPE_SCN.instantiate()
	var input_items : Array[EMC_Item.IDs]
	input_items.append(EMC_Item.IDs.RAVIOLI_TIN)
	ravioli_recipe.setup(input_items, EMC_Item.IDs.RAVIOLI_MEAL, false, true)
	recipe_list.add_child(ravioli_recipe)


func show_gui(p_action : EMC_Action) -> void:
	_action = p_action
	visible = true
	var item_on_slot2 := _inventory.get_item_of_slot(2)
	item_on_slot2.get_ID()
	var component_food : EMC_IC_Food
	for comp in item_on_slot2.get_comps():
		if comp is EMC_IC_Food:
			component_food = comp
	
	#$DecisionWindow/MarginContainer/VBC/RecipeBox/Description.text = \
		#str(component_food.get_formatted_values())
		
	
	# Enter code here if necessary 
	opened.emit()

#MRM: "kochen" better in english?? So far, we translated even the German labels inside Code, dunno
func _on_kochen_pressed() -> void: 
	$SummaryWindow.visible = true 


func _on_abbrechen_pressed() -> void:
	visible = false
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")

#func _meal_selection(inventory: EMC_Inventory) -> Array:
#	if get_electricity_state() = true:
		 
