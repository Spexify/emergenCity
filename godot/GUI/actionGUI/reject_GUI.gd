extends EMC_ActionGUI

@onready var open_gui_sfx := $SFX/OpenGUISFX
@onready var close_gui_sfx := $SFX/CloseGUISFX
@onready var button_sfx := $SFX/ButtonSFX


## Method that should be overwritten in each class that implements E[MC_ActionGUI]:
func show_gui(p_action: EMC_Action) -> void:
	_action = p_action
	open_gui_sfx.play()
	
	var rejected_reasons: String
	for rejected_constraints in _action.get_constraints_rejected():
		rejected_reasons += rejected_constraints
	$NinePatchRect/VBoxContainer/RichTextLabel.text = "Nicht möglich, da: " + rejected_reasons
	
	show()
	opened.emit()


func _on_okay_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	close_gui_sfx.play()
	hide()
	closed.emit()
