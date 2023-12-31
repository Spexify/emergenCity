extends EMC_ActionGUI
class_name EMC_ChangeStageGUI

signal stayed_on_same_stage

@onready var open_gui_sfx = $SFX/OpenGUISFX
@onready var close_gui_sfx = $SFX/CloseGUISFX
@onready var button_sfx = $SFX/ButtonSFX

var _stage_mngr: EMC_StageMngr
var _avatar: EMC_Avatar
## The [EMC_Action]s shall be executed in a "lagging behind" fashion, until you change back to your home
var _last_SC_action: EMC_StageChangeAction

func setup(p_stage_mngr: EMC_StageMngr, p_avatar: EMC_Avatar) -> void:
	_stage_mngr = p_stage_mngr
	_avatar = p_avatar


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action):
	_action = p_action
	var stage_change_action: EMC_StageChangeAction = _action
	
	if _stage_mngr.get_stage_name() == "home":
		#Ohne Meldung/Action zu verbrauchen wechsel, aber [EMC_Action] vormerken
		_on_confirm_btn_pressed()
	elif _stage_mngr.get_stage_name() == stage_change_action.get_stage_name():
		stayed_on_same_stage.emit()
		close()
	else:
		open_gui_sfx.play()
		show()
		opened.emit()


func _on_confirm_btn_pressed():
	var curr_SC_action: EMC_StageChangeAction = _action
	
	_stage_mngr.change_stage(curr_SC_action.get_stage_name())
	_avatar.position = curr_SC_action.get_spawn_pos()
	
	if _last_SC_action != null:
		_last_SC_action.executed.emit(_last_SC_action)
	
	##The change to home should not be executed (at is was skipped initially and should not
	##be protocolled in the SEOD)
	if curr_SC_action.get_stage_name() == "home": 
		_last_SC_action = null
	else:
		_last_SC_action = curr_SC_action
	
	if _stage_mngr.get_stage_name() == "home":
		button_sfx.play()
		await button_sfx.finished
	
	close()


func close():
	close_gui_sfx.play()
	hide()
	closed.emit()


func _on_cancel_btn_pressed():
	button_sfx.play()
	await button_sfx.finished
	close()

