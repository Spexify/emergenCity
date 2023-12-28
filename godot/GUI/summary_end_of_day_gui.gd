extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

signal opened
signal closed
signal on_eat_pressed
signal on_drink_pressed

@onready var open_gui_sfx = $SFX/OpenGUISFX
@onready var close_gui_sfx = $SFX/CloseGUISFX
@onready var button_sfx = $SFX/ButtonSFX

## TODO: add inventory in popup SEOD and choice of food and drinks
var _avatar: EMC_Avatar
var _inventory : EMC_Inventory

var _has_eaten : bool = false
var _has_drank : bool = false

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

func setup(_p_avatar: EMC_Avatar, _p_inventory : EMC_Inventory):
	_avatar = _p_avatar
	_inventory = _p_inventory
	

## opens summary end of day GUI/makes visible
func open(p_day_cycle: EMC_DayCycle, _p_is_game_end : bool):
	open_gui_sfx.play()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox/MorningContent.text = p_day_cycle.morning_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox2/NoonContent.text = p_day_cycle.noon_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox3/EveningContent.text = p_day_cycle.evening_action.get_description()
	visible = true
	if !_p_is_game_end : 
		$SummaryWindow.visible = false
		$DecisionWindow.visible = true
	else: 
		$SummaryWindow.visible = true
		$DecisionWindow.visible = false
	opened.emit()
	print("Hunger : " + str(_avatar.get_hunger_status()))


## closes summary end of day GUI/makes invisible
func close():
	close_gui_sfx.play()
	visible = false
	closed.emit()


## TODO: reduce health and thirst every step, also think about values and coefficent
func _on_continue_pressed():
	_avatar.lower_hunger(1)
	_avatar.lower_thirst(1)
	_avatar.lower_health(1)
	_update_health()
	button_sfx.play()
	$SummaryWindow.visible = true
	$DecisionWindow.visible = false

func _on_new_day_pressed():
	button_sfx.play()
	await button_sfx.finished
	close()


func _on_eat_pressed():
	_avatar.raise_hunger(1)
	_has_eaten = true


func _on_drink_pressed():
	_avatar.raise_thirst(1)
	_has_drank = true
	
func _update_health():
	if _has_drank && _has_eaten:
		_avatar.raise_health(1)
