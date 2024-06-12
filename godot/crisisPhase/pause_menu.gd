extends EMC_GUI

@onready var _electricity_state_icon := $VBC/OverworldStates/VBC/ElectricityState/TextureRect/Sprite2D
@onready var _electricity_state_value := $VBC/OverworldStates/VBC/ElectricityState/Value
@onready var _water_state_icon := $VBC/OverworldStates/VBC/WaterState/TextureRect/Sprite2D
@onready var _water_state_value := $VBC/OverworldStates/VBC/WaterState/Value
@onready var _isolation_state_icon := $VBC/OverworldStates/VBC/IsolationState/TextureRect/Sprite2D
@onready var _isolation_state_value := $VBC/OverworldStates/VBC/IsolationState/Value
@onready var _foodcontam_state_icon := $VBC/OverworldStates/VBC/FoodContamState/TextureRect/Sprite2D
@onready var _foodcontam_state_value := $VBC/OverworldStates/VBC/FoodContamState/Value


########################################## PUBLIC METHODS #########################################
func open(irrelevant : EMC_GUI = null) -> void:
	update_overworld_states()
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit(self)


func update_overworld_states() -> void:
	_electricity_state_icon.frame =  OverworldStatesMngr.get_electricity_state()
	_electricity_state_value.text = "[color=white]" + OverworldStatesMngr.get_electricity_state_descr() + "[/color]"
	_water_state_icon.frame =  OverworldStatesMngr.get_water_state()
	_water_state_value.text = "[color=white]" + OverworldStatesMngr.get_water_state_descr() + "[/color]"
	_isolation_state_icon.frame =  OverworldStatesMngr.get_isolation_state()
	_isolation_state_value.text = "[color=white]" + OverworldStatesMngr.get_isolation_state_descr() + "[/color]"
	
	#Reduced shelflive of food is a special case:
	_foodcontam_state_icon.frame =  OverworldStatesMngr.get_food_contamination_state()
	if _foodcontam_state_icon.frame == OverworldStatesMngr.SemaphoreColors.GREEN && \
	_electricity_state_icon.frame != OverworldStatesMngr.SemaphoreColors.GREEN:
		_foodcontam_state_icon.frame = OverworldStatesMngr.SemaphoreColors.YELLOW
	_foodcontam_state_value.text = "[color=white]" + OverworldStatesMngr.get_food_contamination_state_descr() + "[/color]"


########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	#SettingsGUI.close(true)
	#SettingsGUI.closed.connect(open)

func _exit_tree() -> void:
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
	await Global.save_game(true)
	Global.get_tree().quit()

