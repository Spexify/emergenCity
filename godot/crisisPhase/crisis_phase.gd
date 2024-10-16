class_name EMC_CrisisPhase
extends Node2D

var _backpack: EMC_Inventory = Global.get_inventory()
var _upgrades: Array[EMC_Upgrade] = Global.get_upgrades()
var _dialogue_manager : EMC_DialogueMngr

@onready var _stage_mngr : EMC_StageMngr = $StageMngr
@onready var _avatar : EMC_Avatar = $Avatar

#GUIs Upper Section:
@onready var _day_mngr : EMC_DayMngr = $GUI/CL/VBC/UpperSection/HBC/DayMngr
#GUIs Middle Section:
@onready var _pause_menue := $GUI/CL/VBC/MiddleSection/PauseMenu
@onready var _handy_gui : EMC_Handy = $GUI/CL/HandyGUI
#GUIs Lower Section:
# None

@onready var _gui_mngr : EMC_GUIMngr = $GUI
@onready var stage_mngr :EMC_StageMngr = $StageMngr

#event managers needs to be instantiated here without all parameters because the references are passed to the day_mngr
@onready var _opt_event_mngr: EMC_OptionalEventMngr = EMC_OptionalEventMngr.new(self, _gui_mngr)
@onready var _pu_event_mngr: EMC_PopupEventMngr = EMC_PopupEventMngr.new(_day_mngr, _gui_mngr)

########################################## PUBLIC METHODS ##########################################

########################################## PRIVATE METHODS #########################################
## Setup all the needed reference for GUIs etc.
func _ready() -> void:
	if Global.was_crisis():
		##LOAD SAVE STATE
		Global.load_state()
		
	_avatar.refresh_vitals()

	#Setup-Methoden
	OverworldStatesMngr.setup(_upgrades)
	
	var _action_constraints := EMC_ActionConstraints.new(_day_mngr, _backpack, _stage_mngr)
	var _action_consequences := EMC_ActionConsequences.new(_avatar, _backpack, _stage_mngr, \
		$GUI/CL/VBC/LowerSection, _day_mngr, _gui_mngr, _opt_event_mngr)
	
	#### DialogueStuff
	_dialogue_manager = EMC_DialogueMngr.new(_action_constraints, _action_consequences, _day_mngr, _gui_mngr)
	TradeMngr.setup(_stage_mngr, _backpack)
	
	#### GUI
	_gui_mngr.setup(self, _day_mngr, _backpack, _stage_mngr, _avatar, _opt_event_mngr, _dialogue_manager)
	$GUI/CL/VBC/MiddleSection/IconInformation.hide()
	
	#### Stage
	stage_mngr.setup(_avatar, _day_mngr, _gui_mngr, _opt_event_mngr)
	
	stage_mngr.dialogue_initiated.connect(_dialogue_manager._on_dialogue_initiated)
	
	#### DayMngr
	_day_mngr.setup($Avatar, _stage_mngr, _gui_mngr, _backpack, $GUI/CL/VBC/LowerSection, _opt_event_mngr, \
		_pu_event_mngr)
	
	#Tutorial intro dialogue
	if !Global._tutorial_done: 
		_dialogue_manager._on_dialogue_initiated("extra", "tutorial")

## Up until now, this is only used for keyboard-inputs for debbuging purposes
## As there is no analogous input code on mobile phones, this can be called
## indiscriminately
func _process(delta: float) -> void:
	## DEPRECATED
	#if Input.is_action_just_pressed("ToggleGUI"): #G key
		#var guielem := $GUI/CL/VBC/LowerSection
		#guielem.visible = !guielem.visible
		#$GUI/CL/VBC/MiddleSection.visible = !$GUI/CL/VBC/UpperSection.visible
	## END
	
	if Input.is_action_just_pressed("Toggle_Electricity"):
		if OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.UNLIMITED:
			OverworldStatesMngr.set_electricity_state(OverworldStatesMngr.ElectricityState.NONE)
		else:
			OverworldStatesMngr.set_electricity_state(OverworldStatesMngr.ElectricityState.UNLIMITED)
		_pause_menue.update_overworld_states()
		_handy_gui.restart()
	
	if Input.is_action_just_pressed("Toggle_Water"):
		if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_water_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_water_state(OverworldStatesMngr.get_water_state() + 1)
		_pause_menue.update_overworld_states()
		_handy_gui.restart()
	
	if Input.is_action_just_pressed("Toggle_Isolation"):
		if OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_isolation_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.get_isolation_state() + 1)
		_pause_menue.update_overworld_states()
		_handy_gui.restart()
	
	if Input.is_action_just_pressed("Toggle_Food_Contam"):
		if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_food_contamination_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_food_contamination_state(OverworldStatesMngr.get_food_contamination_state() + 1)
		_pause_menue.update_overworld_states()
		_handy_gui.restart()
		
	if Input.is_action_just_pressed("Toggle_Mobile_Net"):
		if OverworldStatesMngr.get_mobile_net_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_mobile_net_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_mobile_net_state(OverworldStatesMngr.get_mobile_net_state() + 1)
		_handy_gui.restart()

func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"pop_up_manager": _pu_event_mngr.save(),
		"opt_manager": _opt_event_mngr.save(),
	}
	return data
	
func load_state(data : Dictionary) -> void:
	if data.has("pop_up_manager"):
		_pu_event_mngr.load_state(data.get("pop_up_manager"))
		
	if data.has("opt_manager"):
		_opt_event_mngr.load_state(data.get("opt_manager"))
