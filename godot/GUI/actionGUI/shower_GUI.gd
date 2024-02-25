extends EMC_ActionGUI
class_name EMC_ShowerGUI

var _inventory: EMC_Inventory

########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_action = p_action
	
	if _inventory.has_item(EMC_Item.IDs.SOAP):
		$VBoxContainer/HBoxContainer/ConfirmBtn_WithSoap.show()
	else:
		$VBoxContainer/HBoxContainer/ConfirmBtn_WithSoap.hide()
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit()


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()


func _on_confirm_btn_pressed() -> void:
	var health_bonus: int
	#Change the values dependend on the water-state
	match OverworldStatesMngr.get_water_state():
		OverworldStatesMngr.WaterState.CLEAN:
			health_bonus = 2
		OverworldStatesMngr.WaterState.DIRTY:
			health_bonus = 1
		OverworldStatesMngr.WaterState.NONE:
			printerr("No water available!")
			close()
	
	_action.add_consequence("add_health", health_bonus)
	_action.executed.emit(_action)
	close()


func _on_confirm_btn_with_soap_pressed() -> void:
	var health_bonus: int
	#Change the values dependend on the water-state
	match OverworldStatesMngr.get_water_state():
		OverworldStatesMngr.WaterState.CLEAN:
			health_bonus = 3
		OverworldStatesMngr.WaterState.DIRTY:
			health_bonus = 2
		OverworldStatesMngr.WaterState.NONE:
			printerr("No water available!")
			close()
	_action.add_consequence("add_health", health_bonus)
	
	_action.add_consequence("use_item", EMC_Item.IDs.SOAP)
	_action.executed.emit(_action)
	close()


func _on_back_btn_pressed() -> void:
	close()
