extends Node2D

var _backpack: EMC_Inventory = EMC_Inventory.new()

@onready var uncast_guis := $GUI.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Backpack-inventory and its GUI
	_backpack.add_new_item(EMC_Item.IDs.WATER);
	_backpack.add_new_item(EMC_Item.IDs.WATER);
	_backpack.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	_backpack.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	_backpack.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE);
	_backpack.add_new_item(EMC_Item.IDs.WATER_DIRTY);
	
	$GUI/VBC/MiddleSection/BackpackGUI.setup(_backpack, "Rucksack")
	
	
	#GUIs initial verstecken
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.visible = false
	$GUI/VBC/MiddleSection/EndGameGUI.visible = false
	$GUI/VBC/MiddleSection/PopUpGUI.visible = false
	$GUI/VBC/LowerSection/RestGUI.visible = false
	$GUI/VBC/LowerSection/RejectGUI.visible = false
	$GUI/VBC/LowerSection/ChangeStageGUI.visible = false
	$GUI/VBC/MiddleSection/CookingGUI.visible = false
	$GUI/VBC/LowerSection/TooltipGUI.hide()
	
	#Setup-Methoden
	$GUI/VBC/LowerSection/ChangeStageGUI.setup($StageMngr, $Avatar)
	$GUI/VBC/LowerSection/RestGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/LowerSection/RestGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/LowerSection/ChangeStageGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/LowerSection/ChangeStageGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/MiddleSection/PopUpGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/MiddleSection/PopUpGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/MiddleSection/CookingGUI.setup(_backpack)
	
	$StageMngr.setup($Avatar, $GUI/VBC/UpperSection/DayMngr, $CityMap)
	$CityMap.setup($GUI/VBC/UpperSection/DayMngr, $StageMngr, $GUI/VBC/LowerSection/TooltipGUI)
	
	var seodGUI := $GUI/VBC/MiddleSection/SummaryEndOfDayGUI
	var egGUI := $GUI/VBC/MiddleSection/EndGameGUI
	var puGUI := $GUI/VBC/MiddleSection/PopUpGUI
	var guis : Array[EMC_ActionGUI] = []
	#MRM: Because I reworked the node structure of the GUI node, following code
	#needs to be reworked. For now I'll hardcode it.
	#for uncast in uncast_guis:
		#if uncast is EMC_ActionGUI:
			#uncast.opened.connect(_on_action_GUI_opened)
			#uncast.closed.connect(_on_action_GUI_closed)
			#guis.append(uncast as EMC_ActionGUI)
	guis.append($"GUI/VBC/LowerSection/RestGUI" as EMC_ActionGUI)
	guis.append($"GUI/VBC/LowerSection/RejectGUI" as EMC_ActionGUI)
	guis.append($"GUI/VBC/LowerSection/ChangeStageGUI" as EMC_ActionGUI)
	guis.append($"GUI/VBC/MiddleSection/CookingGUI" as EMC_ActionGUI)
	$GUI/VBC/UpperSection/DayMngr.setup($Avatar, guis, seodGUI, egGUI, puGUI)
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.setup($Avatar, _backpack)



func _on_inventory_opened() -> void:
	get_tree().paused = true
	$BtnBackpack.hide()
	get_viewport().set_input_as_handled()


func _on_inventory_closed() -> void:
	get_tree().paused = false
	$BtnBackpack.show()


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch && event.pressed == true):
		if $GUI/VBC/MiddleSection/BackpackGUI.visible && !$BtnBackpack.is_pressed():
			$GUI/VBC/MiddleSection/BackpackGUI.close()


func _on_summary_end_of_day_gui_opened() -> void:
	get_tree().paused = true

func _on_summary_end_of_day_gui_closed() -> void:
	get_tree().paused = false

func _on_action_GUI_opened() -> void:
	get_tree().paused = true

func _on_action_GUI_closed() -> void:
	get_tree().paused = false

