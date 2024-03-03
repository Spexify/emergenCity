extends Node2D
class_name EMC_CrisisPhase


const GERHARD_DIALOG : DialogueResource = preload("res://res/dialogue/gerhard.dialogue")
const FRIEDEL_DIALOG : DialogueResource = preload("res://res/dialogue/friedel.dialogue")
const JULIA_DIALOG : DialogueResource = preload("res://res/dialogue/julia.dialogue")
const PETRO_DIALOG : DialogueResource = preload("res://res/dialogue/petro.dialogue")
const IRENA_DIALOG : DialogueResource = preload("res://res/dialogue/irena.dialogue")
const ELIAS_DIALOG : DialogueResource = preload("res://res/dialogue/elias.dialogue")
const MERT_DIALOG : DialogueResource = preload("res://res/dialogue/mert.dialogue")
const MOMO_DIALOG : DialogueResource = preload("res://res/dialogue/momo.dialogue")
const AGATHE_DIALOG : DialogueResource = preload("res://res/dialogue/agathe.dialogue")
const KRIS_DIALOG : DialogueResource = preload("res://res/dialogue/kris.dialogue")
const VERONIKA_DIALOG : DialogueResource = preload("res://res/dialogue/veronika.dialogue")
const WORKER_DIALOG : DialogueResource = preload("res://res/dialogue/townhall_worker.dialogue")
const WALTER_DIALOG : DialogueResource = preload("res://res/dialogue/walter.dialogue")
const TUTORIAL_DIALOG : DialogueResource = preload("res://res/dialogue/tutorial.dialogue")

const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")
const _BACK_BTN_NAME := "BackButton"

var _backpack: EMC_Inventory = Global.get_inventory()
var _upgrades: Array[EMC_Upgrade] = Global.get_upgrades()
#MRM: I made the OverworldStatesMngr global, see TechDoku for details:
var _crisis_mngr: EMC_CrisisMngr = EMC_CrisisMngr.new()

@onready var uncast_guis := $GUI.get_children()
@onready var _stage_mngr := $StageMngr
@onready var _backpack_btn := $ButtonList/VBC/BackpackBtn
#GUIs Upper Section:
@onready var _status_bars := $GUI/VBC/UpperSection/HBC/StatusBars
@onready var _day_mngr := $GUI/VBC/UpperSection/HBC/DayMngr
#GUIs Middle Section:
@onready var _backpack_GUI := $GUI/VBC/MiddleSection/BackpackGUI
@onready var _SEOD := $GUI/VBC/MiddleSection/SummaryEndOfDayGUI
@onready var _book_GUI := $GUI/VBC/MiddleSection/BookGUI
@onready var _pause_menue := $GUI/VBC/MiddleSection/PauseMenu
@onready var _cooking_GUI := $GUI/VBC/MiddleSection/CookingGUI
@onready var seodGUI := $GUI/VBC/MiddleSection/SummaryEndOfDayGUI
@onready var egGUI := $GUI/VBC/MiddleSection/EndGameGUI
@onready var puGUI := $GUI/VBC/MiddleSection/PopUpGUI
#GUIs Lower Section:
@onready var _tooltip_GUI := $GUI/VBC/LowerSection/TooltipGUI
@onready var _confirmation_GUI := $GUI/VBC/LowerSection/ConfirmationGUI
@onready var _showerGUI := $GUI/VBC/LowerSection/ShowerGUI
@onready var _cs_GUI := $GUI/VBC/LowerSection/ChangeStageGUI

@onready var _opt_event_mngr: EMC_OptionalEventMngr = EMC_OptionalEventMngr.new(_tooltip_GUI)

var _opt_event_consequences_after_dialogue: Dictionary = {}

########################################## PUBLIC METHODS ##########################################

## Notice: Why not Hide Back Button instead? You can use connect with Flag on_shot, so connection will only worj once
func add_back_button(p_on_pressed_callback: Callable) -> void:
	var new_back_button := TextureButton.new()
	new_back_button.texture_normal = load("res://res/gui/button_back.png")
	new_back_button.name = _BACK_BTN_NAME
	new_back_button.pressed.connect(p_on_pressed_callback)
	#new_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
	#new_back_button.pressed.connect(remove_back_button)
	
	#Hide all other back buttons
	#for node: TextureButton in $ButtonList/VBC.get_children():
		#if node.name == _BACK_BTN_NAME:
			#node.hide()
	
	$ButtonList/VBC.add_child(new_back_button)
	$ButtonList/VBC.move_child(new_back_button, 0) #so it appears above all the buttons in the list


## Remove back button once it was pressed
## Notice: Why not Hide Back Button instead? You can use connect with Flag on_shot, so connection will only worj once
func remove_back_button() -> void:
	for node: TextureButton in $ButtonList/VBC.get_children():
		if node.name == _BACK_BTN_NAME:
			$ButtonList/VBC.remove_child(node)
	#Show latest back button if there is one
	#var last_backBtn := $ButtonList/VBC.get_child(0)
	#if last_backBtn.name == _BACK_BTN_NAME:
		#last_backBtn.show()

########################################## PRIVATE METHODS #########################################
## Called when the node enters the scene tree for the first time.
## Setup all the needed reference for GUIs etc.
func _ready() -> void:
	if Global.was_crisis():
		##LOAD SAVE STATE
		Global.load_state()
	
	
	#Setup-Methoden
	OverworldStatesMngr.setup(EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, #(MRM: Changed to NONE to test the shelflife)
		EMC_OverworldStatesMngr.WaterState.CLEAN, _upgrades)
	
	_backpack_GUI.setup(_backpack, $Avatar, _SEOD, "Rucksack", true)
	## NOTICE: connected dialog dont know if this is intendet
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	_crisis_mngr.setup(_backpack)
	_status_bars.setup(_tooltip_GUI)
	_cs_GUI.setup($StageMngr)
	_cooking_GUI.setup(_backpack, _confirmation_GUI, _tooltip_GUI)
	if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		$GUI/VBC/MiddleSection/RainwaterBarrelGUI.setup(OverworldStatesMngr, _backpack)
	_showerGUI.setup(_backpack)
	TradeMngr.setup(_stage_mngr, _backpack)
	
	$StageMngr.setup(self, $Avatar, _day_mngr, _tooltip_GUI, _book_GUI, _cs_GUI, _opt_event_mngr)
	$StageMngr.dialogue_initiated.connect(_on_stage_mngr_dialogue_initiated)
	_SEOD.setup($Avatar, _backpack, _backpack_GUI)
	
	## Collect all Action GUIs in one array for the DayMngr
	var action_guis : Array[EMC_ActionGUI] = []
	action_guis.append(_cs_GUI as EMC_ActionGUI)
	action_guis.append(_cooking_GUI as EMC_ActionGUI)
	if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		action_guis.append($"GUI/VBC/MiddleSection/RainwaterBarrelGUI" as EMC_ActionGUI)
	action_guis.append(_stage_mngr.get_city_map() as EMC_ActionGUI)
	action_guis.append($GUI/VBC/LowerSection/DefaultActionGUI as EMC_ActionGUI)
	action_guis.append(_showerGUI as EMC_ActionGUI)
	action_guis.append(_confirmation_GUI as EMC_ActionGUI)
	
	_day_mngr.setup($Avatar, _stage_mngr, _crisis_mngr, action_guis, _tooltip_GUI, \
		_confirmation_GUI, seodGUI, egGUI, puGUI, _backpack, $GUI/VBC/LowerSection, _opt_event_mngr)
	
	## Connect signals to script-only classes (no Scene/Node so we can't connect it in the editor):
	_day_mngr.period_ended.connect(_opt_event_mngr._on_day_mngr_period_ended)
	_day_mngr.day_ended.connect(_crisis_mngr.check_crisis_status)
	_day_mngr.day_ended.connect(_backpack._on_day_mngr_day_ended)
	
	#Not the nices of solutions:
	_opt_event_mngr.set_constraints(_day_mngr.get_action_constraints())
	_opt_event_mngr.set_consequences(_day_mngr.get_action_consequences())
	
	$DayPeriodTransition._on_day_mngr_day_ended(_day_mngr.get_current_day())
	
	#Tutorial intro dialogue
	if !Global._tutorial_done: _play_tutorial_dialogue()


## Up until now, this is only used for keyboard-inputs for debbuging purposes
## As there is no analogous input code on mobile phones, this can be called
## indiscriminately
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleGUI"): #G key
		var guielem := $GUI/VBC/LowerSection
		guielem.visible = !guielem.visible
		$GUI/VBC/MiddleSection.visible = !$GUI/VBC/UpperSection.visible
	
	if Input.is_action_just_pressed("Toggle_Electricity"):
		if OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_electricity_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_electricity_state(OverworldStatesMngr.get_electricity_state() + 1)
		_pause_menue.update_overworld_states()
	
	if Input.is_action_just_pressed("Toggle_Water"):
		if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_water_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_water_state(OverworldStatesMngr.get_water_state() + 1)
		_pause_menue.update_overworld_states()
	
	if Input.is_action_just_pressed("Toggle_Isolation"):
		if OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_isolation_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_isolation_state(OverworldStatesMngr.get_isolation_state() + 1)
		_pause_menue.update_overworld_states()
	
	if Input.is_action_just_pressed("Toggle_Food_Contam"):
		if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.SemaphoreColors.GREEN:
			OverworldStatesMngr.set_food_contamination_state(int(OverworldStatesMngr.SemaphoreColors.RED))
		else:
			OverworldStatesMngr.set_food_contamination_state(OverworldStatesMngr.get_food_contamination_state() + 1)
		_pause_menue.update_overworld_states()


###################################### DIALOGUE HANDLING ###########################################
func _play_tutorial_dialogue() -> void:
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	$GUI/VBC/LowerSection.add_child(dialogue_GUI)
	dialogue_GUI.start(TUTORIAL_DIALOG, "START")
	get_tree().paused = true
	Global._tutorial_done = true


func _on_stage_mngr_dialogue_initiated(p_NPC_name: String) -> void:
	var dialogue_resource: DialogueResource
	#Theoretically the game is paused so no other DialogueGUI should be instantiated,
	#but for robustness we still make sure there's at most one DialogueGUI
	for node:Node in $GUI/VBC/LowerSection.get_children():
		if node.get_name() == "DialogueGUI":
			return
	
	#MRM: Problems with load on mobile export, so I preload it for now:
	#dialogue_resource = load("res://res/dialogue/" + p_NPC_name + ".dialogue")
	match p_NPC_name:
		"Gerhard": dialogue_resource = GERHARD_DIALOG
		"Friedel": dialogue_resource = FRIEDEL_DIALOG
		"Julia": dialogue_resource = JULIA_DIALOG
		"Petro": dialogue_resource = PETRO_DIALOG
		"Irena": dialogue_resource = IRENA_DIALOG
		"Elias": dialogue_resource = ELIAS_DIALOG
		"Mert": dialogue_resource = MERT_DIALOG
		"Momo": dialogue_resource = MOMO_DIALOG
		"Agathe": dialogue_resource = AGATHE_DIALOG
		"Kris": dialogue_resource = KRIS_DIALOG
		"Veronika": dialogue_resource = VERONIKA_DIALOG
		"TownhallWorker": dialogue_resource = WORKER_DIALOG
		"Walter": dialogue_resource = WALTER_DIALOG
		_:
			printerr("unknown NPC")
			return
	
	
	var starting_tag: String = "START" #English Tag, not "day" meant
	## If you talk to a NPC that got spawned because of an optional event, trigger the dialogue
	## on the tag name after the optional event and save the consequences to execute them once the 
	## dialogue is finished
	for opt_event in _opt_event_mngr.get_active_events():
		var spawn_NPCs_arr := opt_event.spawn_NPCs_arr
		if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
			for spawn_NPCs in spawn_NPCs_arr:
				if _stage_mngr.get_curr_stage_name() == spawn_NPCs.stage_name && \
				p_NPC_name == spawn_NPCs.NPC_name:
					starting_tag = opt_event.name
					_opt_event_consequences_after_dialogue = opt_event.consequences
					#deactivate already the event
					_opt_event_mngr.deactivate_event(opt_event.name)
	
	#Dialogue GUI can't be instantiated in editor, because it eats up all mouse input,
	#even when it's hidden! :(
	#Workaround: Just instantiate it when needed. It's done the same way in the example code
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	$GUI/VBC/LowerSection.add_child(dialogue_GUI)
	
	dialogue_GUI.start(dialogue_resource, starting_tag)
	get_tree().paused = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	Global.get_tree().paused = false
	
	#execute optional event consequences if there are any
	if !_opt_event_consequences_after_dialogue.is_empty():
		for key: String in _opt_event_consequences_after_dialogue.keys():
			var params : Variant = _opt_event_consequences_after_dialogue[key]
			Callable(_day_mngr.get_action_consequences(), key).call(params)
		
		#clear the temporary variable and deactivate the event
		_opt_event_consequences_after_dialogue = {}


################################################################################

func _on_backpack_gui_closed() -> void:
	_backpack_btn.set_pressed(false)


func _on_pause_menu_btn_pressed() -> void:
	$ButtonList/VBC/BackpackBtn.disabled = true
	$GUI/VBC/MiddleSection/PauseMenu.open()


func _on_pause_menu_closed() -> void:
	$ButtonList/VBC/BackpackBtn.disabled = false


func _on_day_mngr_day_ended(p_curr_day: int) -> void:
	var active_crises_descr := OverworldStatesMngr.get_active_crises_descr()
	if active_crises_descr != "":
		_tooltip_GUI.open(active_crises_descr)
	OverworldStatesMngr.clear_active_crises_descr()
