extends EMC_GUI
class_name EMC_EndGameGUI

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
func open(p_history: Array[EMC_DayCycle], p_avatar_life_status : bool, _avatar_ref : EMC_Avatar) -> void:
	
	$WinnerScreen/MarginContainer/VBoxContainer/TextBox3/MarginContainer/ScrollContainer.vertical_scroll_mode = true
	history = p_history
	
	var summary_text_winner : String = ""
	var summary_text_loser : String = ""
	var all_action_coins : int = 0
	var action_coin_value : int = 0
	var actions_summary := {}
	var morning : bool = false
	var noon : bool = false
	var evening : bool = false
	
	
	for action : int in EMC_Action.IDs.values():
		var action_frequency_counter := 0
		var action_name : String = ""
		for day in history:
			if day.morning_action._action_ID == action :
				all_action_coins += day.morning_action.get_performance_coin_value()
				morning = true
				action_frequency_counter += 1
			if day.noon_action._action_ID == action :
				all_action_coins += day.noon_action.get_performance_coin_value()
				noon = true
				action_frequency_counter += 1
			if day.evening_action._action_ID == action :
				all_action_coins += day.evening_action.get_performance_coin_value()
				evening = true
				action_frequency_counter += 1
			if morning : 
				action_coin_value = day.morning_action.get_performance_coin_value()
				action_name = day.morning_action.get_ACTION_NAME()
				morning = false
			if noon : 
				action_coin_value = day.noon_action.get_performance_coin_value()
				action_name = day.noon_action.get_ACTION_NAME()
				noon = false
			if evening : 
				action_coin_value = day.evening_action.get_performance_coin_value()
				action_name = day.evening_action.get_ACTION_NAME()
				evening = false
		
		actions_summary[action_name] = action_frequency_counter
		actions_summary[str(action) + "CoinValue"] = action_coin_value
	
	for key : String in actions_summary:
		if key.contains("CoinValue"):
			continue
		if actions_summary.get(key) != 0:
			summary_text_winner += key + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt und gibt dir jeweils" +\
						str(actions_summary.get(key+"CoinValue")) + " ECoins.\n"
			summary_text_loser += key + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt .\n"
						
	if p_avatar_life_status == false :
		var losing_reason : String = ""
		if _avatar_ref.get_nutrition_status() == 0:
			losing_reason = "Du bist verhungert. "
		if _avatar_ref.get_hydration_status() == 0:
			losing_reason = "Du bist verdurstet. "
		if _avatar_ref.get_health_status() == 0:
			losing_reason = "Du hattest Gesundheitsprobleme. "
			
		$LoserScreen/MarginContainer/VBoxContainer/TextBox3/ScrollContainer/Actions.text \
			= summary_text_loser
		$LoserScreen/MarginContainer/VBoxContainer/TextBox2/Description.text =\
				losing_reason + "Du hast nur 100 ECoins erworben."
		$LoserScreen.visible = true
		$WinnerScreen.visible = false
		Global.set_e_coins(Global.get_e_coins() + 100)
	else: 
		
		$WinnerScreen/MarginContainer/VBoxContainer/TextBox3/MarginContainer/ScrollContainer/Actions.text \
			= summary_text_winner
			
		all_action_coins += _avatar_ref.get_happinness_status()
		Global.set_e_coins(Global.get_e_coins() + all_action_coins)
		$WinnerScreen/MarginContainer/VBoxContainer/TextBox/Description.text =\
				"Du hast " + str(all_action_coins) + " ECoins erworben!"
		all_action_coins = 0
				
		$LoserScreen.visible = false
		$WinnerScreen.visible = true
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
	Global.goto_scene(Global.PREPARE_PHASE_SCENE)
