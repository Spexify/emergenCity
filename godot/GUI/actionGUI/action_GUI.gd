extends EMC_GUI
## TODO
class_name EMC_ActionGUI

signal opened
signal closed

## Value should be set vor each class that implements [EMC_ActionGUI]:
var _action: EMC_Action

## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action : EMC_Action) -> void:
	_action = p_action
	# Enter code here if necessary 
	opened.emit()
