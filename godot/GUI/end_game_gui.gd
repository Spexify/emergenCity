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
	var actions_summary := {}
	for action : String in EMC_Action.IDs:
		var action_frequency_counter := 0
		for day in history:
			if day.morning_action.get_ACTION_NAME().to_upper() == action :
				action_frequency_counter += 1
			if day.noon_action.get_ACTION_NAME().to_upper() == action :
				action_frequency_counter += 1
			if day.evening_action.get_ACTION_NAME().to_upper() == action :
				action_frequency_counter += 1
		actions_summary[action] = action_frequency_counter
	
	var summary_text : String
	for key : String in actions_summary:
		if actions_summary.get(key) != 0:
			summary_text += str(key) + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt.\n"
						
	if avatar_life_status == false :
		$LoserScreen/MarginContainer/VBoxContainer/ScrollContainer/TextBox2/Actions.text \
			= summary_text
		$LoserScreen.visible = true
		$WinnerScreen.visible = false
		Global.set_e_coins(Global.get_e_coins() + 10)
	else: 
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/TextBox2/Actions.text \
			= summary_text
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
