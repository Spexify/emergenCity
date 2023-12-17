extends Control
class_name EMC_PopUpGUI

signal opened
signal closed

var _action : EMC_PopUpAction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open(_p_action : EMC_PopUpAction, _avatar_ref : EMC_Avatar) -> void:
	_action = _p_action
	visible = true
	$PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption.text = _p_action.get_pop_up_text()

## TODO: finish methods
func _on_confirm_pressed():
	_action.executed.emit()


func _on_cancel_pressed():
	$".".visible = false
