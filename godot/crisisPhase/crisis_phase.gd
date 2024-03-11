extends Node2D
class_name EMC_CrisisPhase


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

#event managers needs to be instantiated here without all parameters because the references are passed to the day_mngr
@onready var _opt_event_mngr: EMC_OptionalEventMngr = EMC_OptionalEventMngr.new(_tooltip_GUI)
@onready var _pu_event_mngr: EMC_PopupEventMngr = EMC_PopupEventMngr.new(_day_mngr, puGUI)

########################################## PUBLIC METHODS ##########################################

## Notice: Why not Hide Back Button instead? You can use connect with Flag on_shot, so connection will only worj once
func add_back_button(p_on_pressed_callback: Callable) -> void:
	var new_back_button := TextureButton.new()
	new_back_button.texture_normal = load("res://res/gui/button_back.png")
	new_back_button.name = _BACK_BTN_NAME
	new_back_button.pressed.connect(p_on_pressed_callback)
	new_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
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
	$InputBlock.hide()
	OverworldStatesMngr.setup(_upgrades)
	
	_backpack_GUI.setup(_backpack, $Avatar, _SEOD, "Rucksack", true)
	## NOTICE: connected dialog dont know if this is intendet
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	_crisis_mngr.setup(_backpack, _tooltip_GUI)
	_status_bars.setup(_tooltip_GUI)
	_cs_GUI.setup($StageMngr)
	_cooking_GUI.setup(_backpack, _confirmation_GUI, _tooltip_GUI)
	if(Global.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		$GUI/VBC/MiddleSection/RainwaterBarrelGUI.setup(OverworldStatesMngr, _backpack)
	_showerGUI.setup()
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
		_confirmation_GUI, seodGUI, egGUI, _backpack, $GUI/VBC/LowerSection, _opt_event_mngr, \
		_pu_event_mngr, $DayPeriodTransition)
	
	#Not the nicest of solutions:
	_opt_event_mngr.set_constraints(_day_mngr.get_action_constraints())
	_opt_event_mngr.set_consequences(_day_mngr.get_action_consequences())
	_pu_event_mngr.set_constraints(_day_mngr.get_action_constraints())
	_pu_event_mngr.set_consequences(_day_mngr.get_action_consequences())
	
	#Tutorial intro dialogue
	if !Global._tutorial_done: 
		_play_tutorial_dialogue()
		$GUI/VBC/MiddleSection/IconInformation.open()
		Global._tutorial_done = true

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
	Global.get_tree().paused = true


func _on_stage_mngr_dialogue_initiated(p_NPC_name: String) -> void:
	var dialogue_resource: DialogueResource
	#Theoretically the game is paused so no other DialogueGUI should be instantiated,
	#but for robustness we still make sure there's at most one DialogueGUI
	for node:Node in $GUI/VBC/LowerSection.get_children():
		if node.get_name() == "DialogueGUI":
			return
	
	dialogue_resource = load("res://res/dialogue/" + p_NPC_name.to_lower() + ".dialogue")
	
	var starting_tag: String = "START" #English Tag, not "day" meant
	## If you talk to a NPC that got spawned because of an optional event, trigger the dialogue
	## on the tag name after the optional event and save the consequences to execute them once the 
	## dialogue is finished
	for opt_event in _opt_event_mngr.get_active_events():
		if _stage_mngr.get_curr_stage_name() == opt_event.stage_name:
			var spawn_NPCs_arr := opt_event.spawn_NPCs_arr
			if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
				for spawn_NPCs in spawn_NPCs_arr:
					if p_NPC_name == spawn_NPCs.NPC_name:
						starting_tag = opt_event.name
	
	#Dialogue GUI can't be instantiated in editor, because it eats up all mouse input,
	#even when it's hidden! :(
	#Workaround: Just instantiate it when needed. It's done the same way in the example code
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	$GUI/VBC/LowerSection.add_child(dialogue_GUI)
	
	dialogue_GUI.start(dialogue_resource, starting_tag, [_opt_event_mngr])
	Global.get_tree().paused = true


## Is called when a dialogue ends
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	#Block input for a while, so no accidental misclicks happen
	const INPUT_BLOCK_DURATION: float = 0.4
	$InputBlock.show()
	await Global.get_tree().create_timer(INPUT_BLOCK_DURATION).timeout
	$InputBlock.hide()
	
	Global.get_tree().paused = false


################################################################################
## Handle the click on the backpack-button
func _on_backpack_btn_pressed() -> void:
	if _backpack_GUI.visible == false:
		_backpack_GUI.open()
		$ButtonList/VBC/BackpackBtn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	else:
		_backpack_GUI.close()
		$ButtonList/VBC/BackpackBtn.process_mode = Node.PROCESS_MODE_PAUSABLE


func _on_pause_menu_btn_pressed() -> void:
	$ButtonList/VBC/PauseMenuBtn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$GUI/VBC/MiddleSection/PauseMenu.open()


func _on_pause_menu_closed() -> void:
	$ButtonList/VBC/PauseMenuBtn.process_mode = Node.PROCESS_MODE_PAUSABLE


func _on_stage_mngr_city_map_opened() -> void:
	$ButtonList/VBC/PauseMenuBtn.hide()
	$ButtonList/VBC/BackpackBtn.hide()


func _on_stage_mngr_city_map_closed() -> void:
	$ButtonList/VBC/PauseMenuBtn.show()
	$ButtonList/VBC/BackpackBtn.show()

