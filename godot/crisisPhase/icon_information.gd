extends EMC_GUI
class_name EMC_Icon_Information_GUI


func open() -> void:
	show()
	opened.emit()


func _on_continue_btn_pressed() -> void:
	close()


func close() -> void:
	hide()
	closed.emit()


func _ready() -> void:
	close()
