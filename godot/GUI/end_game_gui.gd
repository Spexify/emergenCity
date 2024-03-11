extends EMC_GUI
class_name EMC_EndGameGUI
## Improvement idea: Instead of having two almost identical copies "WinnerScreen" and "LoserScreen"
## just have one and change the contents... That's a lot better because with each copy there is, the
## amount of work you have to do when making changes doubles (and you might overlook/forget to make
## changes for both)


func _ready() -> void:
	hide()


## opens summary end of day GUI/makes visible
func open(p_history: Array[EMC_DayCycle], p_avatar_life_status : bool, _avatar : EMC_Avatar) -> void:
	
	$WinnerScreen/MarginContainer/VBoxContainer/TextBox3/MarginContainer/ScrollContainer.vertical_scroll_mode = true
	
	var summary_text_winner : String = ""
	var summary_text_loser : String = ""
	var all_action_coins : int = 0
	var action_coin_value : int = 0
	var actions_summary := {}
	var morning : bool = false
	var noon : bool = false
	var evening : bool = false
	
	Global.get_tree().paused = true
	
	for action : int in EMC_Action.IDs.values():
		var action_frequency_counter := 0
		var action_name : String = ""
		for day in p_history:
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
		actions_summary[action_name + "CoinValue"] = action_coin_value
	
	for key : String in actions_summary:
		if key.contains("CoinValue"):
			continue
		if actions_summary.get(key) != 0:
			summary_text_winner += key + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt und gibt dir jeweils " +\
						str(actions_summary.get(key+"CoinValue")) + " ECoins.\n"
			summary_text_loser += key + " wurde " + str(actions_summary.get(key)) +\
						 " Mal ausgeführt .\n"
						
	if p_avatar_life_status == false :
		var losing_reason : String = ""
		if _avatar.get_nutrition_status() == 0:
			losing_reason = "Du bist unterernährt und wurdest vom Notfalldienst gerettet. "
		elif _avatar.get_hydration_status() == 0:
			losing_reason = "Du bist dehydriert und wurdest vom Notfalldienst gerettet. "
		elif _avatar.get_health_status() == 0:
			losing_reason = "Du hast eine Gesundheitskrise und wurdest vom Notfalldienst gerettet. "
			
		$LoserScreen/MarginContainer/VBoxContainer/TextBox3/ScrollContainer/Actions.text \
			= summary_text_loser
		var end_coins := Global.get_e_coins() + p_history.size()*30
		$LoserScreen/MarginContainer/VBoxContainer/TextBox2/Description.text =\
				losing_reason + "Du hast nur " + str(end_coins) +" ECoins erworben."
		$LoserScreen.show()
		$WinnerScreen.hide()
		Global.set_e_coins(end_coins)
	else: 
		summary_text_winner += "BONUS: Glücklichkeitsbalke beträgt " + str(_avatar.get_unit_happiness_status()) + " Prozent."
		$WinnerScreen/MarginContainer/VBoxContainer/TextBox3/MarginContainer/ScrollContainer/Actions.text \
			= summary_text_winner

		all_action_coins += _avatar.get_unit_happiness_status()
		Global.set_e_coins(Global.get_e_coins() + all_action_coins)
		$WinnerScreen/MarginContainer/VBoxContainer/TextBox/Description.text =\
				"Du hast " + str(all_action_coins) + " ECoins erworben!"
		all_action_coins = 0
				
		$LoserScreen.hide()
		$WinnerScreen.show()
		$StarExplosionVFX.emitting = true
	
	show()
	opened.emit()


## closes summary end of day GUI/makes invisible
func close() -> void:
	Global.get_tree().paused = false
	hide()
	closed.emit()


func _on_main_menu_pressed() -> void:
	Global.get_tree().paused = false
	Global.reset_state()
	Global.reset_inventory()
	Global.reset_upgrades_equipped()
	Global.save_game(false)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
