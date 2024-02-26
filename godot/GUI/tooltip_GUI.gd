extends EMC_GUI
class_name EMC_TooltipGUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func open(p_text: String) -> void:
	$VBoxContainer/PanelContainer/RichTextLabel.text = "[color=black]" + p_text + "[/color]"
	get_tree().paused = true
	show()
	opened.emit()


func _on_back_btn_pressed() -> void:
	get_tree().paused = false
	hide()
	closed.emit()
