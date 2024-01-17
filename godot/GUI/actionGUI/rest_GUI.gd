extends EMC_ActionGUI
class_name EMC_RestActionGUI

@onready var open_gui_sfx := $SFX/OpenGUISFX
@onready var close_gui_sfx := $SFX/CloseGUISFX
@onready var button_sfx := $SFX/ButtonSFX

## Method that should be overwritten in each class that implements E[MC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_action = p_action
	open_gui_sfx.play()
	show()
	opened.emit()


func _on_okay_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	close_gui_sfx.play()
	hide()
	closed.emit()
	#MRM: Bugfix: Execute Action AFTER closed.emit, so potentially
	# following GUIs (like PopupEvents or SEOD) are opened after this one is closed
	_action.executed.emit(_action)


func _on_cancel_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	close_gui_sfx.play()
	hide()
	closed.emit()
