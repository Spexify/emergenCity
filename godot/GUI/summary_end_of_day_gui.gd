extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

signal on_eat_pressed
signal on_drink_pressed

var _avatar: EMC_Avatar
var _inventory_GUI : EMC_InventoryGUI
var _inventory : EMC_Inventory
const _INV_SCN : PackedScene = preload("res://GUI/inventory_GUI.tscn")
const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
var _has_slept : int = 0 


func setup(_p_avatar: EMC_Avatar, _p_inventory : EMC_Inventory, _p_inventory_GUI_ref: EMC_InventoryGUI) -> void:
	_avatar = _p_avatar
	_inventory = _p_inventory
	_inventory_GUI = _p_inventory_GUI_ref
	_inventory_GUI.close_button.connect(_open_summary_window)


func _open_summary_window() -> void:
	$SummaryWindow.visible = true
	Global.set_gui_active(true)


## opens summary end of day GUI/makes visible
func open(_p_day_cycle: EMC_DayCycle) -> void:
	if _p_day_cycle.morning_action._action_ID == 3: #MRM: TODO exchange magic numbers
		_has_slept +=1
	if _p_day_cycle.noon_action._action_ID == 3: 
		_has_slept +=1
	if _p_day_cycle.evening_action._action_ID == 3: 
		_has_slept +=1
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox/MorningContent.text = _p_day_cycle.morning_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox2/NoonContent.text = _p_day_cycle.noon_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox3/EveningContent.text = _p_day_cycle.evening_action.get_description()
	visible = true
	Global.set_gui_active(true)
	opened.emit()


## closes summary end of day GUI/makes invisible
func close() -> void:
	visible = false
	Global.set_gui_active(false)
	closed.emit()
	_inventory_GUI.set_consume_idle() #MRM Bugfix


#MRM: Technically the values should be subtracted when opening the screen but the 
#gameover-conditions should be checked only when a new day section is started inside the DayMngr
func _on_continue_pressed() -> void:
	_inventory_GUI.set_consume_active(_has_slept)
	_inventory_GUI.open()
	_has_slept = 0
	#close_gui_sfx.play()
	visible = false


#func _on_inventory_gui_seod_inventory_closed()-> void:
	#close()
