extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

@onready var morning_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC1/TextBox/MorningContent
@onready var noon_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC2/TextBox/NoonContent
@onready var evening_content : RichTextLabel = $SummaryWindow/MarginContainer/VBC/VBC/HBC3/TextBox/EveningContent

## opens summary end of day GUI/makes visible
func open(_p_day_cycle: EMC_DayCycle) -> void:
	morning_content.text = _p_day_cycle.morning_action.get_description()
	noon_content.text = _p_day_cycle.noon_action.get_description()
	evening_content.text = _p_day_cycle.evening_action.get_description()
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
