extends EMC_ActionGUI

var _inventory: EMC_Inventory
	
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory

func show_gui(p_action : EMC_Action):
	_action = p_action
	visible = true
	var item_on_slot2 = _inventory.get_item_of_slot(2)
	item_on_slot2.get_ID()
	var component_food : EMC_IC_Food
	for comp in item_on_slot2.get_comps():
		if comp is EMC_IC_Food:
			component_food = comp
	
	$DecisionWindow/MarginContainer/VBoxContainer/TextBox/Description.text = \
		str(component_food.get_formatted_values())
		
	
	# Enter code here if necessary 
	opened.emit()


func _on_kochen_pressed():
	$SummaryWindow.visible = true 


func _on_abbrechen_pressed():
	visible = false
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")
