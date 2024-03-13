extends Control
class_name EMC_Information

const BBK_BROCHURE_LINK := "https://www.bbk.bund.de/SharedDocs/Downloads/DE/Mediathek/Publikationen/Buergerinformationen/Ratgeber/ratgeber-notfallvorsorge.pdf?__blob=publicationFile&v=15"

func open() -> void:
	show()


func close() -> void:
	hide()

static func open_bbk_brochure() -> void:
	OS.shell_open(BBK_BROCHURE_LINK)


func _on_texture_button_pressed() -> void:
	hide()
	Global.goto_scene("res://preparePhase/main_menu.tscn")


## TODO: Name could be improved: "cooking" sounds like the in-game mechanic
func _on_cooking_button_pressed() -> void:
	OS.shell_open("https://www.bbk.bund.de/DE/Warnung-Vorsorge/Tipps-Notsituationen/Kochen-ohne-Strom/kochen-ohne-strom_node.html")


func _on_bbk_button_pressed() -> void:
	open_bbk_brochure()


