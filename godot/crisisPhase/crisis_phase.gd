extends Node2D
class_name EMC_CrisisPhase


const TUTORIAL_DIALOG : DialogueResource = preload("res://res/dialogue/tutorial.dialogue")
const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")
const _BACK_BTN_NAME := "BackButton"

var _backpack: EMC_Inventory = Global.get_inventory()
var _upgrades: Array[EMC_Upgrade] = Global.get_upgrades()
#MRM: I made the OverworldStatesMngr global, see TechDoku for details:
var _crisis_mngr: EMC_CrisisMngr = EMC_CrisisMngr.new()

@onready var _stage_mngr : EMC_StageMngr = $StageMngr
@onready var _avatar : EMC_Avatar = $Avatar

#GUIs Upper Section:
@onready var _day_mngr : EMC_DayMngr = $GUI/CL/VBC/UpperSection/HBC/DayMngr
#GUIs Middle Section:
@onready var _backpack_GUI : EMC_InventoryGUI = $GUI/CL/VBC/MiddleSection/BackpackGUI
@onready var _book_GUI : EMC_BookGUI = $GUI/CL/VBC/MiddleSection/BookGUI
@onready var _pause_menue := $GUI/CL/VBC/MiddleSection/PauseMenu
@onready var _cooking_GUI := $GUI/CL/VBC/MiddleSection/CookingGUI
@onready var _showerGUI := $GUI/CL/VBC/LowerSection/ShowerGUI
@onready var seodGUI : EMC_SummaryEndOfDayGUI = $GUI/CL/VBC/MiddleSection/SummaryEndOfDayGUI
@onready var egGUI : EMC_EndGameGUI = $GUI/CL/VBC/MiddleSection/EndGameGUI
@onready var puGUI : EMC_PopUpGUI = $GUI/CL/VBC/MiddleSection/PopUpGUI
#GUIs Lower Section:
@onready var _tooltip_GUI : EMC_TooltipGUI = $GUI/CL/VBC/LowerSection/TooltipGUI
@onready var _confirmation_GUI : EMC_ConfirmationGUI = $GUI/CL/VBC/LowerSection/ConfirmationGUI
@onready var _cs_GUI : EMC_ChangeStageGUI = $GUI/CL/VBC/LowerSection/ChangeStageGUI

@onready var _gui_mngr : EMC_GUIMngr = $GUI


#event managers needs to be instantiated here without all parameters because the references are passed to the day_mngr
@onready var _opt_event_mngr: EMC_OptionalEventMngr = EMC_OptionalEventMngr.new(self, _tooltip_GUI)
@onready var _pu_event_mngr: EMC_PopupEventMngr = EMC_PopupEventMngr.new(_day_mngr, puGUI)

########################################## PUBLIC METHODS ##########################################

## Notice: Why not Hide Back Button instead? You can use connect with Flag on_shot, so connection will only worj once
func add_back_button(p_on_pressed_callback: Callable) -> void:
	var new_back_button := TextureButton.new()
	new_back_button.texture_normal = preload("res://res/sprites/GUI/buttons/button_back.png")
	new_back_button.name = _BACK_BTN_NAME
	new_back_button.pressed.connect(p_on_pressed_callback)
	new_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
	#new_back_button.pressed.connect(remove_back_button)
	
	#Hide all other back buttons
	#for node: TextureButton in $ButtonList/VBC.get_children():
		#if node.name == _BACK_BTN_NAME:
			#node.hide()
	
	$GUI/ButtonList/VBC.add_child(new_back_button)
	$GUI/ButtonList/VBC.move_child(new_back_button, 0) #so it appears above all the buttons in the list


## Remove b fwack button once it was pressed
## Notice: Why not Hide Back Button instead? You can use connect with Flag on_shot, so connection will only worj once
func remove_back_button() -> void:
	for node: TextureButton in $GUI/ButtonList/VBC.get_children():
		if node.name == _BACK_BTN_NAME:
			$GUI/ButtonList/VBC.remove_child(node)
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
	
	_gui_mngr.setup(self, _day_mngr, _backpack, _stage_mngr, _avatar, _opt_event_mngr)
	
	## NOTICE: connected dialog dont know if this is intendet
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	_crisis_mngr.setup(_backpack, _gui_mngr)
	TradeMngr.setup(_stage_mngr, _backpack)
	
	$StageMngr.setup(self, $Avatar, _day_mngr, _gui_mngr, _opt_event_mngr)
	$StageMngr.dialogue_initiated.connect(_on_stage_mngr_dialogue_initiated)
	
	_day_mngr.setup($Avatar, _stage_mngr, _crisis_mngr, _gui_mngr, _backpack, $GUI/CL/VBC/LowerSection, _opt_event_mngr, \
		_pu_event_mngr, $Animations/DayPeriodTransition)
	
	#Not the nicest of solutions:
	_opt_event_mngr.set_constraints(_day_mngr.get_action_constraints())
	_opt_event_mngr.set_consequences(_day_mngr.get_action_consequences())
	_pu_event_mngr.set_constraints(_day_mngr.get_action_constraints())
	_pu_event_mngr.set_consequences(_day_mngr.get_action_consequences())
	
	$GUI/CL/VBC/MiddleSection/IconInformation.hide()
	
	#Tutorial intro dialogue
	if !Global._tutorial_done: 
		_play_tutorial_dialogue()


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


func play_rain_anim() -> void:
	await $Animations/RainAnimation.play()

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
	if !Global._tutorial_done:
		$GUI/VBC/MiddleSection/IconInformation.open()
		Global._tutorial_done = true
