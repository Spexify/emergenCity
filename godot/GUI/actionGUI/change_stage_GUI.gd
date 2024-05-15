extends EMC_ActionGUI
class_name EMC_ChangeStageGUI

signal stayed_on_same_stage

@onready var _richtext_label := $NinePatchRect/MarginContainer/VBoxContainer/RichTextLabel

var _stage_mngr: EMC_StageMngr
## The [EMC_Action]s shall be executed in a "lagging behind" fashion, until you change back to your home
var _last_SC_action: EMC_StageChangeAction
var _previously_paused: bool


func setup(p_stage_mngr: EMC_StageMngr) -> void:
	_stage_mngr = p_stage_mngr


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_previously_paused = Global.get_tree().paused
	Global.get_tree().paused = true
	_action = p_action
	var stage_change_action: EMC_StageChangeAction = _action
	
	if _stage_mngr.get_curr_stage_name() == stage_change_action.get_stage_name():
		close() #Order important: First close yourself, then emit signal
		stayed_on_same_stage.emit()
	else:
		if _stage_mngr.get_curr_stage_name() == "home":
			_richtext_label.text = tr("CG_BEFORE") + " " + \
				stage_change_action.get_ACTION_NAME() + tr("CG_AFTER1")
		else:
			_richtext_label.text = tr("CG_BEFORE") + " " + \
				stage_change_action.get_ACTION_NAME() + tr("CG_AFTER2")
		show()
		opened.emit()


func _on_confirm_btn_pressed() -> void:
	#First close the GUI (order important, as the pause-mode otherwise isn't set back correctly)
	close()
	
	var curr_SC_action: EMC_StageChangeAction = _action #downcast
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = curr_SC_action.play_sound()
	if wait != null:
		await wait.finished
	
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
	


func close() -> void:
	Global.get_tree().paused = _previously_paused
	hide()
	closed.emit()


func _on_cancel_btn_pressed() -> void:
	close()


func _ready() -> void:
	hide()
