extends EMC_ActionGUI
class_name EMC_RestActionGUI


func _init():
	_type_gui = "rest_GUI"


## Method that should be overwritten in each class that implements E[MC_ActionGUI]:
func show_gui(p_action: EMC_Action):
	_action = p_action
	show()
	opened.emit()


func _on_okay_pressed():
	_action.executed.emit(_action)
	hide()
	closed.emit()


func _on_cancel_pressed():
	hide()
	closed.emit()
