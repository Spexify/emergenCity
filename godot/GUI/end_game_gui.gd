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
func open(p_history: Array[EMC_DayCycle], p_avatar_life_status : bool) -> void:
	
	$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer.vertical_scroll_mode = true
	history = p_history
	
	
	var summary_text_winner : String = ""
	var summary_text_loser : String = ""
	var all_action_coins : int = 0
	var action_coin_value : int = 0
	var actions_summary := {}
	var morning : bool = false
	var noon : bool = false
	var evening : bool = false
	
	for action : String in EMC_Action.IDs:
		var action_frequency_counter := 0
		for day in history:
			if day.morning_action.get_ACTION_NAME().to_upper() == action :
				action_coin_value += day.morning_action.get_performance_coin_value()
				morning = true
				action_frequency_counter += 1
			if day.noon_action.get_ACTION_NAME().to_upper() == action :
				action_coin_value += day.noon_action.get_performance_coin_value()
				noon = true
				action_frequency_counter += 1
			if day.evening_action.get_ACTION_NAME().to_upper() == action :
				action_coin_value += day.evening_action.get_performance_coin_value()
				evening = true
				action_frequency_counter += 1
			if morning : 
				action_coin_value = day.morning_action.get_performance_coin_value()
				morning = false
			if noon : 
				action_coin_value = day.noon_action.get_performance_coin_value()
				noon = false
			if evening : 
				action_coin_value = day.evening_action.get_performance_coin_value()
				evening = false
			
		actions_summary[action] = action_frequency_counter
		actions_summary[action + "CoinValue"] = action_coin_value
	
	for key : String in actions_summary:
		if key.contains("CoinValue"):
			continue
		if actions_summary.get(key) != 0:
			summary_text_winner += str(key) + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt und gibt dir jeweils" +\
						str(actions_summary.get(key+"CoinValue")) + " ECoins.\n"
			all_action_coins += actions_summary.get(key)*actions_summary.get(key+"CoinValue")
			summary_text_loser += str(key) + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt .\n"
						
	if p_avatar_life_status == false :
		$LoserScreen/MarginContainer/VBoxContainer/ScrollContainer/TextBox2/Actions.text \
			= summary_text_loser
		$LoserScreen.visible = true
		$WinnerScreen.visible = false
		Global.set_e_coins(Global.get_e_coins() + 100)
	else: 
		$WinnerScreen/MarginContainer/VBoxContainer/ScrollContainer/TextBox2/Actions.text \
			= summary_text_winner
		$WinnerScreen/MarginContainer/VBoxContainer/TextBox/Description.text =\
				"Du hast " + str(all_action_coins) + " ECoins erworben!"
		all_action_coins = 0
		$LoserScreen.visible = false
		$WinnerScreen.visible = true
		Global.set_e_coins(Global.get_e_coins() + all_action_coins)
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
	get_tree().paused = false
	Global.reset_state()
	Global.goto_scene("res://preparePhase/main_menu.tscn")
