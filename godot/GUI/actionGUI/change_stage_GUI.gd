extends EMC_ActionGUI
class_name EMC_ChangeStageGUI

signal stayed_on_same_stage

@onready var _richtext_label := $NinePatchRect/MarginContainer/VBoxContainer/RichTextLabel

var _stage_mngr: EMC_StageMngr
## The [EMC_Action]s shall be executed in a "lagging behind" fashion, until you change back to your home
var _last_SC_action: EMC_StageChangeAction


func setup(p_stage_mngr: EMC_StageMngr) -> void:
	_stage_mngr = p_stage_mngr


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_action = p_action
	var stage_change_action: EMC_StageChangeAction = _action
	
	if _stage_mngr.get_curr_stage_name() == stage_change_action.get_stage_name():
		stayed_on_same_stage.emit()
		close()
	else:
		if _stage_mngr.get_curr_stage_name() == "home":
			_richtext_label.text = "Willst du " + \
				stage_change_action.get_ACTION_NAME() + " gehen? Die Rückkehr kostet eine Aktion."
		else:
			_richtext_label.text = "Willst du " + \
				stage_change_action.get_ACTION_NAME() + " gehen? Dies kostet eine Aktion."
		show()
		opened.emit()


func _on_confirm_btn_pressed() -> void:
	var curr_SC_action: EMC_StageChangeAction = _action
	
	curr_SC_action.silent_executed.emit(curr_SC_action)
	
	if _last_SC_action != null:
		var tmp : Dictionary = _last_SC_action._consequences.duplicate(true)
		_last_SC_action._consequences = {}
		_last_SC_action.executed.emit(_last_SC_action)
		_last_SC_action._consequences = tmp
	
	###The change to home should not be executed (at is was skipped initially and should not
	###be protocolled in the SEOD)
	if not curr_SC_action.progresses_day_period(): 
		_last_SC_action = null
	else:
		_last_SC_action = curr_SC_action
	
	close()


func close() -> void:
	hide()
	closed.emit()


func _on_cancel_btn_pressed() -> void:
	close()


func _ready() -> void:
	hide()
