extends EMC_GUI
class_name EMC_Icon_Information_GUI

func open() -> void:
	Global.get_tree().paused = false
	visible = false
	opened.emit()

func _on_continue_btn_pressed() -> void:
	close()
	
func close() -> void:
	Global.get_tree().paused = false
	visible = false
	closed.emit()