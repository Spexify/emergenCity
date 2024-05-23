extends EMC_GUI
class_name EMC_PopUpGUI #should probably be called "PUEventGUI" as only Pop-up EVENTS use it

var _current_action : EMC_PopUpAction

func _ready() -> void:
	hide()


func open(_p_action : EMC_PopUpAction) -> void:
	_current_action = _p_action
	show()
	SoundMngr.vibrate(250, 2)
	opened.emit()
	$PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption.set_text(_p_action.get_pop_up_text())


func close() -> void:
	hide()
	closed.emit()


func _on_confirm_pressed() -> void:
	close()
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = _current_action.play_sound()
	if wait != null:
		await wait.finished
	
	if _current_action.progresses_day_period():
		_current_action.silent_executed.emit(_current_action) 
	else:
		_current_action.executed.emit(_current_action)


func _on_cancel_pressed() -> void:
	var tmp_dict : Dictionary = _current_action._consequences	# I know not pretty but fast inplemented
	_current_action._consequences = _current_action._cancel_consequences
	_current_action.silent_executed.emit(_current_action)
	_current_action._consequences = tmp_dict
	close()
