extends EMC_ActionGUI
class_name EMC_ChangeStageGUI

@onready var open_gui_sfx = $SFX/OpenGUISFX
@onready var close_gui_sfx = $SFX/CloseGUISFX
@onready var button_sfx = $SFX/ButtonSFX

var _stage_mngr: EMC_StageMngr
var _avatar: EMC_Avatar

func setup(p_stage_mngr: EMC_StageMngr, p_avatar: EMC_Avatar) -> void:
	_stage_mngr = p_stage_mngr
	_avatar = p_avatar


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func show_gui(p_action: EMC_Action):
	_action = p_action
	
	if _stage_mngr.get_stage_name() == "home":
		_on_confirm_btn_pressed() #Ohne Meldung weitermachen
	else:
		open_gui_sfx.play()
		show()
		opened.emit()


func _on_confirm_btn_pressed():
	var stageChangeAction: EMC_StageChangeAction = _action
	#print("Stage wechseln zu " + stageChangeAction.get_stage_name())
	#print(_stage_mngr.get_stage_name())
	if _stage_mngr.get_stage_name() != "home":
		_action.executed.emit(_action)
	_stage_mngr.change_stage(stageChangeAction.get_stage_name())
	_avatar.position = stageChangeAction.get_spawn_pos()
	
	if _stage_mngr.get_stage_name() == "home":
		button_sfx.play()
		await button_sfx.finished
		close_gui_sfx.play()
	
	hide()
	closed.emit()


func _on_cancel_btn_pressed():
	button_sfx.play()
	await button_sfx.finished
	close_gui_sfx.play()
	
	hide()
	closed.emit()

