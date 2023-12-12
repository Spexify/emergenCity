extends EMC_GUI
## TODO
class_name EMC_ActionGUI

signal opened
signal closed

## Value should be set vor each class that implements [EMC_ActionGUI]:
var _type_gui: String = ""
var _action: EMC_Action

## Method that should be overwritten in each class that implements E[MC_ActionGUI]:
func show_gui(p_action : EMC_Action):
	_action = p_action
	# Enter code here if necessary 
	opened.emit()


func get_type_gui():
	return self._type_gui
