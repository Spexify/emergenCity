extends EMC_ActionGUI
class_name EMC_ConfirmationGUI

signal decided

var _confirmed: bool


func _ready() -> void:
	hide()

#see
#https://docs.godotengine.org/de/4.x/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines
func confirm(p_question: String) -> bool:
	$VBoxContainer/PanelContainer/RichTextLabel.text = p_question
	show()
	await decided
	return _confirmed


func close() -> void:
	hide()
	closed.emit()


func _on_confirmation_btn_pressed() -> void:
	_confirmed = true
	close()
	decided.emit()


func _on_button_pressed() -> void:
	_confirmed = false
	close()
	decided.emit()
