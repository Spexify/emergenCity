extends EMC_ActionGUI

var _inventory: EMC_Inventory

func _init():
	_type_gui = "cooking_GUI"
	
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory

func show_gui(p_action : EMC_Action):
	_action = p_action
	visible = true
	var item_on_slot2 = _inventory.get_item_ID_of_slot(2)
	$DecisionWindow/MarginContainer/VBoxContainer/TextBox/Description.text = \
		str(item_on_slot2)
		
	
	# Enter code here if necessary 
	opened.emit()


func _on_kochen_pressed():
	$SummaryWindow.visible = true 


func _on_abbrechen_pressed():
	visible = false
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")
