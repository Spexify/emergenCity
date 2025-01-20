extends EMC_ActionGUI
class_name EMC_ChangeStageGUI

@onready var _richtext_label := $NinePatchRect/MarginContainer/VBoxContainer/RichTextLabel

var _stage_mngr: EMC_StageMngr
## The [EMC_Action]s shall be executed in a "lagging behind" fashion, until you change back to your home
var _last_SC_action: EMC_StageChangeAction
var _prev_gui : EMC_CityMap

func setup(p_stage_mngr: EMC_StageMngr) -> void:
	_stage_mngr = p_stage_mngr

## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func open(p_action: EMC_Action, p_prev_gui : EMC_CityMap) -> void:
	_action = p_action
	_prev_gui = p_prev_gui
	var stage_change_action: EMC_StageChangeAction = _action
	
	if _stage_mngr.get_curr_stage_name() == stage_change_action.get_stage_name():
		close() #Order important: First close yourself, then emit signal
	else:
		if _stage_mngr.get_curr_stage_name() == "home":
			_richtext_label.text = "Willst du [b]" + \
				stage_change_action.get_ACTION_NAME() + "[/b] gehen? Die Rückkehr kostet eine Aktion."
		else:
			_richtext_label.text = "Willst du [b]" + \
				stage_change_action.get_ACTION_NAME() + "[/b] gehen? Dies kostet eine Aktion."
		show()
		opened.emit()


func _on_confirm_btn_pressed() -> void:
	#First close the GUI (order important, as the pause-mode otherwise isn't set back correctly)
	close()
	
	var curr_SC_action: EMC_StageChangeAction = _action
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = curr_SC_action.play_sound()
	if wait != null:
		await wait.finished
	
	if _last_SC_action == null:
		curr_SC_action._progresses_day_period = false
		curr_SC_action.silent_executed.emit(curr_SC_action)
		curr_SC_action._progresses_day_period = true
	else:
		curr_SC_action.silent_executed.emit(curr_SC_action)

		var tmp : Dictionary = _last_SC_action._consequences.duplicate(true)
		_last_SC_action._consequences = {}
		_last_SC_action.executed.emit(_last_SC_action)
		_last_SC_action._consequences = tmp
	
	###The change to home should not be executed (at is was skipped initially and should not
	###be protocolled in the SEOD)
	if curr_SC_action.get_consequences()["change_stage"]["stage_name"] == "home": 
		_last_SC_action = null
	else:
		_last_SC_action = curr_SC_action
	
	# Close CityMap
	_prev_gui.close()

func close() -> void:
	hide()
	closed.emit(self)

func _on_cancel_btn_pressed() -> void:
	close()

func _ready() -> void:
	hide()
