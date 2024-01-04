extends EMC_GUI
class_name EMC_EndGameGUI

signal opened
signal closed

@onready var open_gui_sfx := $SFX/OpenGUISFX
@onready var close_gui_sfx := $SFX/CloseGUISFX
@onready var button_sfx := $SFX/ButtonSFX

var history : Array [EMC_DayCycle]

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

## opens summary end of day GUI/makes visible
func open(p_history: Array[EMC_DayCycle], avatar_life_status : bool) -> void:
	$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer.vertical_scroll_mode = true
	history = p_history
	for day in history:
		## creating labels for each day of the history
		var day_label := Label.new()
		day_label.text = "Day" + str(day)
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/Days.add_child(day_label)
		## filling content of each day of the history
		var morning := PanelContainer.new()
		var morningContent := Label.new()
		morningContent.text = day.morning_action.get_ACTION_NAME()
		morning.add_child(morningContent)
		var noon := PanelContainer.new()
		var noonContent := Label.new()
		noonContent.text = day.noon_action.get_ACTION_NAME()
		noon.add_child(noonContent)
		var evening := PanelContainer.new()
		var eveningContent := Label.new()
		eveningContent.text = day.evening_action.get_ACTION_NAME()
		evening.add_child(eveningContent)
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/DailyContent.add_child(morning)
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/DailyContent.add_child(noon)
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer/DailyContent.add_child(evening)
		
	if avatar_life_status == false :
		$LoserScreen.visible = true
		$WinnerScreen.visible = false
		Global.set_e_coins(Global.get_e_coins() + 10)
	else: 
		$LoserScreen.visible = false
		$WinnerScreen.visible = true
		Global.set_e_coins(Global.get_e_coins() + 50)
		open_gui_sfx.play()
	visible = true
	opened.emit()

## closes summary end of day GUI/makes invisible
func close() -> void:
	close_gui_sfx.play()
	visible = false
	closed.emit()


func _on_main_menu_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://preparePhase/main_menu.tscn")
