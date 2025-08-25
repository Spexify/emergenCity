class_name EMC_CrisisPhase
extends Node2D

var _backpack: EMC_Inventory = Global.get_inventory()
var _dialogue_manager : EMC_DialogueMngr

#@onready var _stage_mngr : EMC_StageMngr = $StageMngr
@onready var _avatar : EMC_Avatar = $Avatar

#GUIs Upper Section:
@onready var _day_mngr : EMC_DayMngr = $GUI/CL/VBC/UpperSection/HBC/DayMngr
#GUIs Middle Section:
#@onready var _pause_menue := $GUI/CL/VBC/MiddleSection/PauseMenu
@onready var _handy_gui : EMC_Handy = $GUI/CL/HandyGUI
@onready var info_center_gui: EMC_Info_Center = $GUI/CL/VBC/MiddleSection/InfoCenterGui
@onready var icon_information: EMC_Icon_Information_GUI = $GUI/CL/VBC/MiddleSection/IconInformation
#GUIs Lower Section:
# None

@onready var _gui_mngr: EMC_GUIMngr = $GUI
@onready var stage_mngr: EMC_StageMngr = $StageMngr

#event managers needs to be instantiated here without all parameters because the references are passed to the day_mngr
@onready var _opt_event_mngr: EMC_OptionalEventMngr = EMC_OptionalEventMngr.new(self, _gui_mngr)

@onready var _action_consequences: EMC_ActionConsequences = $EMC_ActionConsequences
@onready var _action_constraints: EMC_ActionConstraints = $EMC_ActionConstraints
@onready var _scoreboard: EMC_Scoreboard = $EMC_Scoreboard


########################################## PUBLIC METHODS ##########################################

########################################## PRIVATE METHODS #########################################

func _get_comp(comp_name: String) -> Node:
	match comp_name:
		"gui_mngr":
			return _gui_mngr
		"day_mngr":
			return _day_mngr
		"OSM":
			return OverworldStatesMngr
		"SoundMngr":
			return SoundMngr
		"ActCons":
			return _action_consequences
		"ActCond": 
			return _action_constraints
		"Score":
			return _scoreboard
		_:
			return self

## Setup all the needed reference for GUIs etc.
func _ready() -> void:
	OverworldStatesMngr.reset()
	
	if Global.was_crisis():
		##LOAD SAVE STATE
		Global.load_state()
	
	#Setup-Methoden
	_avatar.refresh_vitals()

	JsonMngr.set_action_comp(_get_comp)
	
	_scoreboard.start_run(_backpack, OverworldStatesMngr.get_difficulty(), OverworldStatesMngr.get_upgardes_id())
	
	_action_constraints.setup(_backpack)
	
	_action_consequences.setup( _backpack, _opt_event_mngr)
	
	#### DialogueStuff
	_dialogue_manager = EMC_DialogueMngr.new(_action_constraints, _action_consequences, _day_mngr, _gui_mngr)
	
	#### GUI
	_gui_mngr.setup(_backpack, _opt_event_mngr, _dialogue_manager)
	icon_information.hide()
	
	#### Stage
	stage_mngr.setup(_opt_event_mngr)
	
	stage_mngr.npc_interaction.connect(_gui_mngr._on_npc_interaction)
	
	#### DayMngr
	_day_mngr.setup(_backpack, _opt_event_mngr)
	
	#Tutorial intro dialogue
	if !Global._tutorial_done: 
		_dialogue_manager._on_dialogue_initiated("extra", "tutorial")

## Up until now, this is only used for keyboard-inputs for debbuging purposes
## As there is no analogous input code on mobile phones, this can be called
## indiscriminately
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("Toggle_Electricity"):
		#if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"):
			### Overrides effective state, this will be reset when a new crisis changes the state
			#OverworldStatesMngr.facility_effective_states["ElectricityState"] = OverworldStatesMngr.STATE_TRANSLATOR["ElectricityState"]["NONE"]
		#else:
			#OverworldStatesMngr.facility_effective_states["ElectricityState"] = OverworldStatesMngr.STATE_TRANSLATOR["ElectricityState"]["UNLIMITED"]
		##_pause_menue.update_overworld_states()
		#_handy_gui.restart()
		#info_center_gui.reload()
	#
	#if Input.is_action_just_pressed("Toggle_Water"):
		#if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			#OverworldStatesMngr.set_water_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		#else:
			#OverworldStatesMngr.set_water_state(OverworldStatesMngr.get_water_state() + 1)
		##_pause_menue.update_overworld_states()
		#_handy_gui.restart()
		#info_center_gui.reload()
	#
	#if Input.is_action_just_pressed("Toggle_Isolation"):
		#if OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			#OverworldStatesMngr.set_isolation_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		#else:
			#OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.get_isolation_state() + 1)
		##_pause_menue.update_overworld_states()
		#_handy_gui.restart()
		#info_center_gui.reload()
	#
	#if Input.is_action_just_pressed("Toggle_Food_Contam"):
		#if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			#OverworldStatesMngr.set_food_contamination_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		#else:
			#OverworldStatesMngr.set_food_contamination_state(OverworldStatesMngr.get_food_contamination_state() + 1)
		##_pause_menue.update_overworld_states()
		#_handy_gui.restart()
		#info_center_gui.reload()
		#
	#if Input.is_action_just_pressed("Toggle_Mobile_Net"):
		#if OverworldStatesMngr.get_mobile_net_state() == OverworldStatesMngr.MobileNetState.ONLINE:
			#OverworldStatesMngr.set_mobile_net_state(OverworldStatesMngr.MobileNetState.OFFLINE)
		#else:
			#OverworldStatesMngr.set_mobile_net_state(OverworldStatesMngr.MobileNetState.ONLINE)
		#_handy_gui.restart()
		#info_center_gui.reload()
		
func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"opt_manager": _opt_event_mngr.save(),
	}
	return data
	
func load_state(data : Dictionary) -> void:
	if data.has("opt_manager"):
		_opt_event_mngr.load_state(data.get("opt_manager"))
