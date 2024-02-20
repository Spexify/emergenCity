extends NinePatchRect
class_name EMC_TooltipGUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func open(p_text: String) -> void:
	$VBoxContainer/PanelContainer/RichTextLabel.text = "[color=black]" + p_text + "[/color]"
	get_tree().paused = true
	Global.set_gui_active(true)
	show()


func _on_back_btn_pressed() -> void:
	get_tree().paused = false
	Global.set_gui_active(false)
	hide()
