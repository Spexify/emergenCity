extends EMC_GUI
class_name EMC_PopUpGUI #should probably be called "PUEventGUI" as only Pop-up EVENTS use it

var _current_action : EMC_PopUpAction
var _previous_pause_state: bool

func _ready() -> void:
	hide()


func open(_p_action : EMC_PopUpAction) -> void:
	_previous_pause_state = Global.get_tree().paused
	Global.get_tree().paused = true
	show()
	_current_action = _p_action
	opened.emit()
	$PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption.set_text(_p_action.get_pop_up_text())


func close() -> void:
	Global.get_tree().paused = _previous_pause_state
	hide()
	closed.emit()


func _on_confirm_pressed() -> void:
	close()
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
