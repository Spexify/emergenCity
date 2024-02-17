extends Control

func open() -> void:
	show()


func close() -> void:
	hide()


func _on_texture_button_pressed() -> void:
	hide()
	Global.goto_scene("res://preparePhase/main_menu.tscn")


func _on_cooking_button_pressed() -> void:
	OS.shell_open("https://www.bbk.bund.de/DE/Warnung-Vorsorge/Tipps-Notsituationen/Kochen-ohne-Strom/kochen-ohne-strom_node.html")


func _on_bbk_button_pressed() -> void:
	OS.shell_open("https://www.bbk.bund.de/SharedDocs/Downloads/DE/Mediathek/Publikationen/Buergerinformationen/Ratgeber/ratgeber-notfallvorsorge.pdf?__blob=publicationFile&v=15")
