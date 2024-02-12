extends Control

func open() -> void:
	show()


func close() -> void:
	hide()


func _on_texture_button_pressed() -> void:
	hide()
	Global.goto_scene("res://preparePhase/main_menu.tscn")
