extends Control
class_name  EMC_GUIMngr

#GUIs Upper Section:
@onready var _status_bars := $CL/VBC/UpperSection/HBC/StatusBars
#GUIs Middle Section:
@onready var _backpack_GUI : EMC_InventoryGUI = $CL/VBC/MiddleSection/BackpackGUI
@onready var _cooking_GUI : EMC_GUI = $CL/VBC/MiddleSection/CookingGUI
@onready var seodGUI : EMC_SummaryEndOfDayGUI = $CL/VBC/MiddleSection/SummaryEndOfDayGUI
@onready var item_question_gui : EMC_ItemQuestion= $CL/VBC/MiddleSection/ItemQuestionGUI
@onready var handy_gui : EMC_Handy = $CL/VBC/MiddleSection/HandyGUI
#GUIs Lower Section:
@onready var _tooltip_GUI := $CL/VBC/LowerSection/TooltipGUI
@onready var _confirmation_GUI := $CL/VBC/LowerSection/ConfirmationGUI
@onready var _showerGUI := $CL/VBC/LowerSection/ShowerGUI
@onready var _cs_GUI : EMC_ChangeStageGUI = $CL/VBC/LowerSection/ChangeStageGUI
@onready var _rainwater_barrel_gui := $CL/VBC/MiddleSection/RainwaterBarrelGUI


@onready var middle_section := $CL/VBC/MiddleSection
@onready var lower_section := $CL/VBC/LowerSection

@onready var _city_map : EMC_CityMap = $CL/CityMap
@onready var _day_period_transition : EMC_GUI = $CL/DayPeriodTransition
@onready var _rain_animation : EMC_GUI = $CL/RainAnimation

@onready var pause_menu_btn := $ButtonList/VBC/PauseMenuBtn
@onready var backpack_btn := $ButtonList/VBC/BackpackBtn
@onready var phone_btn := $ButtonList/VBC/PhoneBtn

@onready var canvas_modulate := $CanvasModulate


signal all_guis_closed

var all_the_guis : Array[EMC_GUI]
var _prev_gui : EMC_GUI
var _active_guis : Array[EMC_GUI]
var _gui_queue : Array[QueueEntry]

var _stage_mngr : EMC_StageMngr
var _avatar : EMC_Avatar

func _ready() -> void:
	for child in middle_section.get_children():
		all_the_guis.append(child)
		
	for child in lower_section.get_children():
		all_the_guis.append(child)
		
	all_the_guis.append(_city_map)
	all_the_guis.append(_rain_animation)
	all_the_guis.append(_day_period_transition)
	
	_set_guis_process_mode(all_the_guis, PROCESS_MODE_DISABLED)

# Called when the node enters the scene tree for the first time.
func setup(p_crisis_phase : EMC_CrisisPhase, p_day_mngr : EMC_DayMngr,  p_backpack : EMC_Inventory, \
			p_stage_mngr : EMC_StageMngr, p_avatar : EMC_Avatar, p_opt_event_mngr : EMC_OptionalEventMngr) -> void:
	
	_stage_mngr = p_stage_mngr
	_avatar = p_avatar
	
	_city_map.setup(p_crisis_phase, p_day_mngr, p_stage_mngr, self, p_opt_event_mngr)
	
	_backpack_GUI.setup(p_backpack, p_avatar, self, "Rucksack")
	
	item_question_gui.setup(p_backpack, p_avatar)
	
	_status_bars.setup(self)
	_cs_GUI.setup(p_stage_mngr)
	_cooking_GUI.setup(p_backpack, self, p_day_mngr)
	if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		_rainwater_barrel_gui.setup(OverworldStatesMngr, p_backpack)
	_showerGUI.setup(p_backpack)

func is_any_gui() -> bool:
	return not (_active_guis.is_empty() and _gui_queue.is_empty())

func request_gui(gui_name : String, argv : Array) -> Variant:
	for gui in all_the_guis:
		if gui.name == gui_name:
			_hide_buttons()
			_status_bars.set_process_mode(PROCESS_MODE_DISABLED)
			_stage_mngr.set_process_mode(PROCESS_MODE_DISABLED)
			_avatar.set_process_mode(PROCESS_MODE_DISABLED)
			
			if gui_name == "ChangeStageGUI":
				argv.append(_active_guis.back())
				
			canvas_modulate.show()
			
			var result : Variant = gui.callv("open", argv)
			
			if not _active_guis.is_empty():
				_active_guis.back().set_process_mode(PROCESS_MODE_DISABLED)
			_active_guis.append(gui)
			gui.set_process_mode(PROCESS_MODE_INHERIT)
			
			if gui_name == "ConfirmationGUI":
				return result
			
			return gui.closed
	printerr("Gui with name: '" + gui_name + "' not found")
	return Signal()

func queue_gui(gui_name : String, argv : Array) -> Signal:
	if _active_guis.is_empty():
		return request_gui(gui_name, argv)
	else:
		for gui in all_the_guis:
			if gui.name == gui_name:
				_gui_queue.append(QueueEntry.new(gui, argv))
				return gui.closed
	return Signal()

func gui_closed(gui : EMC_GUI) -> void:
	_active_guis.erase(gui)
	if not _active_guis.is_empty():
		_active_guis.back().set_process_mode(PROCESS_MODE_INHERIT)
	elif not _gui_queue.is_empty():
		var entry : QueueEntry = _gui_queue.pop_front()
		entry.gui.callv("open", entry.argv)
		entry.gui.set_process_mode(PROCESS_MODE_INHERIT)
		_active_guis.append(entry.gui)
	else:
		canvas_modulate.hide()
		_show_buttons()
		_status_bars.set_process_mode(PROCESS_MODE_INHERIT)
		_stage_mngr.set_process_mode(PROCESS_MODE_INHERIT)
		_avatar.set_process_mode(PROCESS_MODE_INHERIT)
		
		all_guis_closed.emit()

########################Signal Handlers############################

func _on_backpack_btn_pressed() -> void:
	request_gui("BackpackGUI", [])

func _on_pause_menu_btn_pressed() -> void:
	request_gui("PauseMenu", [])
	
func _on_phone_btn_pressed() -> void:
	request_gui("HandyGUI", [])

########################Helper Functions############################

func _set_guis_process_mode(guis : Array[EMC_GUI], mode : int) -> void:
	for gui in guis:
		gui.set_process_mode(mode)
		gui.closed.connect(gui_closed)
		
func _hide_buttons() -> void:
	pause_menu_btn.hide()
	phone_btn.hide()
	backpack_btn.hide()
	
func _show_buttons() -> void:
	pause_menu_btn.show()
	phone_btn.show()
	backpack_btn.show()

######################Helper Classes##############################

class QueueEntry:
	var gui : EMC_GUI
	var argv : Array
	
	func _init(p_gui : EMC_GUI, p_argv : Array) -> void:
		gui = p_gui
		argv = p_argv
