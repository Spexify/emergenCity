extends EMC_GUI


########################################## PUBLIC METHODS #########################################
func open(irrelevant : EMC_GUI = null) -> void:
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	#SettingsGUI.close(true)
	#SettingsGUI.closed.connect(open)

func _exit_tree() -> void:
	if closed.is_connected(open):
		SettingsGUI.closed.disconnect(open)

func _on_resume_btn_pressed() -> void:
	close()


func _on_settings_pressed() -> void:
	hide()
	SettingsGUI.open(true)
	SettingsGUI.closed.connect(open, CONNECT_ONE_SHOT)

## TODO
func _on_cancel_curr_crisis_pressed() -> void:
	OverworldStatesMngr._set_all_states(2, 2, 2, 2)
	Global.reset_state()
	Global.reset_inventory()
	Global.reset_upgrades_equipped()
	Global.save_game(false)
	Global.get_tree().paused = false
	Global.goto_scene(Global.MAIN_MENU_SCENE)


## TODO
func _on_save_and_quit_pressed() -> void:
	Global.save_game(true)
	Global.get_tree().quit()

