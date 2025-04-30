extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

@onready var morning_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC1/TextBox/MorningContent
@onready var noon_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC2/TextBox/NoonContent
@onready var evening_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC3/TextBox/EveningContent

## opens summary end of day GUI/makes visible
func open(history: Array[String]) -> void:
	morning_content.text = history[0]
	noon_content.text = history[1]
	evening_content.text = history[2]
	show()
	opened.emit()

## closes summary end of day GUI/makes invisible
func close() -> void:
	hide()
	closed.emit(self)

func _on_continue_pressed() -> void:
	close()

func _ready() -> void:
	hide()
