extends EMC_ActionGUI


func _init():
	_type_gui = "reject_GUI"


## Method that should be overwritten in each class that implements E[MC_ActionGUI]:
func show_gui(p_action: EMC_Action):
	_action = p_action
	
	var rejected_reasons: String
	for rejected_constraints in _action.get_constraints_rejected():
		rejected_reasons += rejected_constraints
	$NinePatchRect/VBoxContainer/RichTextLabel.text = "Nicht möglich, da: " + rejected_reasons
	
	show()
	opened.emit()


func _on_okay_pressed():
	hide()
	closed.emit()
