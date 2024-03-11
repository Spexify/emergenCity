extends EMC_ActionGUI
class_name EMC_DefaultActionGUI


########################################## PUBLIC METHODS ##########################################
## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_action = p_action
	$VBoxContainer/PanelContainer/RichTextLabel.text = _action.get_prompt()
	
	if _action.progresses_day_period():
		$VBoxContainer/HBoxContainer/ConfirmBtn_NoIcon.hide()
		$VBoxContainer/HBoxContainer/ConfirmBtn.show()
	else:
		$VBoxContainer/HBoxContainer/ConfirmBtn_NoIcon.show()
		$VBoxContainer/HBoxContainer/ConfirmBtn.hide()
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit()


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()


func _on_confirm_btn_pressed() -> void:
	_action.executed.emit(_action)
	var wait : Signal = _action.play_sound()
	if not wait.is_null():
		await wait
	close()


func _on_back_btn_pressed() -> void:
	close()

