extends EMC_ActionGUI
class_name EMC_DefaultActionGUI

@onready var confirm_btn : Button = $VBoxContainer/HBoxContainer/ConfirmBtn
@onready var confirm_btn_no_icon : Button = $VBoxContainer/HBoxContainer/ConfirmBtn_NoIcon
@onready var back_btn : Button = $VBoxContainer/HBoxContainer/BackBtn
@onready var description : RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel


########################################## PUBLIC METHODS ##########################################
## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func open(p_action: EMC_Action) -> void:
	_action = p_action
	description.text = _action.get_prompt()
	
	if _action.progresses_day_period():
		confirm_btn_no_icon.hide()
		confirm_btn.show()
	else:
		confirm_btn_no_icon.show()
		confirm_btn.hide()
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit(self)


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()

func _on_confirm_btn_pressed() -> void:
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = _action.play_sound()
	##Don't wait, because it causes problems because you can still click somewherelse
	##while the SFX is playing. (Made SoundMngr process always)
	#if wait != null:
		#await wait.finished
	
	_action.executed.emit(_action)
	close()

func _on_back_btn_pressed() -> void:
	close()

