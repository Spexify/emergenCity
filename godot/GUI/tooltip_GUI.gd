extends NinePatchRect
class_name EMC_TooltipGUI

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func open(p_text: String):
	$VBoxContainer/PanelContainer/RichTextLabel.text = "[color=black]" + p_text + "[/color]"
	get_tree().paused = true
	show()


func _on_back_btn_pressed():
	get_tree().paused = false
	hide()
