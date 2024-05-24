extends Control
class_name  EMC_GUIMngr

#GUIs Upper Section:
@onready var _status_bars := $CL/VBC/UpperSection/HBC/StatusBars
#GUIs Middle Section:
@onready var _backpack_GUI : EMC_InventoryGUI = $CL/VBC/MiddleSection/BackpackGUI
@onready var _cooking_GUI := $CL/VBC/MiddleSection/CookingGUI
@onready var seodGUI : EMC_SummaryEndOfDayGUI = $CL/VBC/MiddleSection/SummaryEndOfDayGUI
#GUIs Lower Section:
@onready var _tooltip_GUI := $CL/VBC/LowerSection/TooltipGUI
@onready var _confirmation_GUI := $CL/VBC/LowerSection/ConfirmationGUI
@onready var _showerGUI := $CL/VBC/LowerSection/ShowerGUI
@onready var _cs_GUI : EMC_ChangeStageGUI = $CL/VBC/LowerSection/ChangeStageGUI
@onready var _rainwater_barrel_gui := $CL/VBC/MiddleSection/RainwaterBarrelGUI

@onready var middle_section := $CL/VBC/MiddleSection
@onready var lower_section := $CL/VBC/LowerSection

@onready var _city_map : EMC_CityMap = $CL/CityMap

@onready var pause_menu_btn := $ButtonList/VBC/PauseMenuBtn
@onready var backpack_btn := $ButtonList/VBC/BackpackBtn

@onready var canvas_modulate := $CanvasModulate

var all_the_guis : Array[EMC_GUI]
var _prev_gui : EMC_GUI
var _handel_input : bool = false

var _active_gui_count : int 

func _ready() -> void:
	for child in middle_section.get_children():
		all_the_guis.append(child)
		
	for child in lower_section.get_children():
		all_the_guis.append(child)
		
	all_the_guis.append(_city_map)

# Called when the node enters the scene tree for the first time.
func setup(p_crisis_phase : EMC_CrisisPhase, p_day_mngr : EMC_DayMngr,  p_backpack : EMC_Inventory, \
			p_stage_mngr : EMC_StageMngr, p_avatar : EMC_Avatar, p_opt_event_mngr : EMC_OptionalEventMngr) -> void:
	#Setup-Methoden
	#all_the_guis.append(p_stage_mngr.get_city_map())
	
	_city_map.setup(p_crisis_phase, p_day_mngr, p_stage_mngr, self, p_opt_event_mngr)
	
	_backpack_GUI.setup(p_backpack, p_avatar, seodGUI, "Rucksack", true)
	
	_status_bars.setup(_tooltip_GUI)
	_cs_GUI.setup(p_stage_mngr)
	_cooking_GUI.setup(p_backpack, _confirmation_GUI, _tooltip_GUI)
	if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		_rainwater_barrel_gui.setup(OverworldStatesMngr, p_backpack)
	_showerGUI.setup(p_backpack)
	seodGUI.setup(p_avatar, p_backpack, _backpack_GUI)

	#if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		#action_guis.append($"GUI/VBC/MiddleSection/RainwaterBarrelGUI" as EMC_ActionGUI)

func request_gui(gui_name : String, argv : Array) -> Signal:
	for gui in all_the_guis:
		if gui.name == gui_name:
			_handel_input = true
			_hide_buttons()
			
			if gui_name == "CityMap":
				_prev_gui = gui
			if gui_name == "ChangeStageGUI":
				argv.append(_prev_gui)
				
			canvas_modulate.show()
			gui.closed.connect(gui_closed, CONNECT_ONE_SHOT)
			
			gui.callv("open", argv)
			_active_gui_count += 1
			return gui.closed
	return Signal()

func gui_closed() -> void:
	_active_gui_count -= 1
	
	if _active_gui_count <= 0:
		canvas_modulate.hide()
		_handel_input = false
		_show_buttons()

func _gui_input(event : InputEvent) -> void:
	if _handel_input:
		accept_event() #get_viewport().set_input_as_handled()
		
func _hide_buttons() -> void:
	pause_menu_btn.hide()
	backpack_btn.hide()
	
func _show_buttons() -> void:
	pause_menu_btn.show()
	backpack_btn.show()
	
func _on_backpack_btn_pressed() -> void:
	request_gui("BackpackGUI", [])

func _on_pause_menu_btn_pressed() -> void:
	request_gui("PauseMenu", [])
