extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

signal opened
signal closed
signal on_eat_pressed
signal on_drink_pressed

@onready var open_gui_sfx := $SFX/OpenGUISFX
@onready var close_gui_sfx := $SFX/CloseGUISFX
@onready var button_sfx := $SFX/ButtonSFX

## TODO: add inventory in popup SEOD and choice of food and drinks
var _avatar: EMC_Avatar
var _inventory : EMC_InventoryGUI
const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")

var _has_eaten : bool 
var _has_drank : bool 

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

func setup(_p_avatar: EMC_Avatar, _p_inventory : EMC_Inventory) -> void:
	_avatar = _p_avatar
	_inventory = EMC_InventoryGUI.new()
	_inventory.setup(_p_inventory, "Essen/Trinken" , false)
	$DecisionWindow/MarginContainer/VBoxContainer.add_child(_inventory)
	

## opens summary end of day GUI/makes visible
func open(p_day_cycle: EMC_DayCycle) -> void:
	open_gui_sfx.play()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox/MorningContent.text = p_day_cycle.morning_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox2/NoonContent.text = p_day_cycle.noon_action.get_description()
	$SummaryWindow/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TextBox3/EveningContent.text = p_day_cycle.evening_action.get_description()
	visible = true
	$SummaryWindow.visible = false
	$DecisionWindow.visible = true
	opened.emit()


## closes summary end of day GUI/makes invisible
func close() -> void:
	close_gui_sfx.play()
	visible = false
	closed.emit()


## TODO: think about eating and drinking untis and updating health accordingly
#MRM: Technically the values should be subtracted when opening the screen but the 
#gameover-conditions should be checked only when a new day section is started inside the DayMngr
func _on_continue_pressed() -> void:
	_update_health()
	button_sfx.play()
	$SummaryWindow.visible = true
	$DecisionWindow.visible = false


func _on_new_day_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	close()

## KL: TODO: eating and drinking in correspondace with the inventory
func _on_eat_pressed() -> void:
	_avatar.add_nutrition(1)
	_has_eaten = true
	#var _food_inventory = EMC_InventoryGUI.new().setup(_inventory.filter_items(0), "Essensvorrat")
	
	
func _on_drink_pressed() -> void:
	_avatar.add_hydration(1)
	_has_drank = true
	#var _food_inventory = EMC_InventoryGUI.new().setup(_inventory.filter_items(1), "Getränkenvorrat")
	
	
func _update_health() -> void:
	if _has_drank && _has_eaten:
		_avatar.add_health(1)

