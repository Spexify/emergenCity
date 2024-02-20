extends EMC_GUI
class_name EMC_PopUpGUI

var _current_action : EMC_PopUpAction
#var _action_consequences : EMC_ActionConsequences

#func setup(p_action_consequences : EMC_ActionConsequences) -> void:
	#_action_consequences = p_action_consequences

func open(_p_action : EMC_PopUpAction) -> void:
	#moved action consequences to DayMngr, as we can use them there for normal actions too
	_current_action = _p_action
	show()
	Global.set_gui_active(true)
	opened.emit()
	$PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption.set_text(_p_action.get_pop_up_text())


func _on_confirm_pressed() -> void:	
	hide()
	Global.set_gui_active(false)
	closed.emit()
	_current_action.executed.emit(_current_action) 


func _on_cancel_pressed() -> void:
	$".".visible = false
	Global.set_gui_active(false)
	closed.emit()
