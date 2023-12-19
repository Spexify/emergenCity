extends Control
class_name EMC_PopUpGUI


signal opened
signal closed

var _action : EMC_PopUpAction
var _avatar_ref : EMC_Avatar

func open(_p_action : EMC_PopUpAction, _p_avatar_ref : EMC_Avatar) -> void:
	_action = _p_action
	_avatar_ref = _p_avatar_ref
	visible = true
	$PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption.text = _p_action.get_pop_up_text()

## TODO: finish methods
func _on_confirm_pressed():
	#MRM: Wir hatten vergessen dem emit die Aktion auch als Parameter zu geben (ist nötig):
	_action.executed.emit(_action) 
	visible = false #MRM hat gefehlt :)


func _on_cancel_pressed():
	$".".visible = false
