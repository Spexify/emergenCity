extends Node2D
class_name EMC_CrisisPhase

const GERHARD_DIALOG : DialogueResource = preload("res://res/dialogue/gerhard.dialogue")
const JULIA_DIALOG : DialogueResource = preload("res://res/dialogue/julia.dialogue")
const FRIEDEL_DIALOG : DialogueResource = preload("res://res/dialogue/friedel.dialogue")
const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")
const _BACK_BTN_NAME := "BackButton"

var _backpack: EMC_Inventory = Global.get_inventory()
#MRM: I made the OverworldStatesMngr global, see TechDoku for details:
var _overworld_states_mngr: EMC_OverworldStatesMngr = OverworldStatesMngr #EMC_OverworldStatesMngr.new()
var _crisis_mngr : EMC_CrisisMngr = EMC_CrisisMngr.new()

@onready var uncast_guis := $GUI.get_children()
@onready var _stage_mngr := $StageMngr
@onready var _backpack_btn := $ButtonList/VBC/BackpackBtn


########################################## PUBLIC METHODS ##########################################
func add_back_button(p_on_pressed_callback: Callable) -> void:
	var new_back_button := TextureButton.new()
	new_back_button.texture_normal = load("res://res/gui/button_back.png")
	new_back_button.name = _BACK_BTN_NAME
	new_back_button.pressed.connect(p_on_pressed_callback)
	#new_back_button.pressed.connect(remove_back_button)
	$ButtonList/VBC.add_child(new_back_button)
	$ButtonList/VBC.move_child(new_back_button, 0) #so it appears above all the buttons in the list


## Remove back button once it was pressed
func remove_back_button() -> void:
	for node: TextureButton in $ButtonList/VBC.get_children():
		if node.name == _BACK_BTN_NAME:
			$ButtonList/VBC.remove_child(node)


########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.was_crisis():
		####################LOAD SAVE STATE#######################
		Global.load_state()
		
	#TODO: Upgrades should later be initialized and passed by the UpgradeCenter
	var _upgrades: Array[EMC_OverworldStatesMngr.Furniture] = [EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL]
	_overworld_states_mngr.setup(EMC_OverworldStatesMngr.ElectricityState.NONE, #(MRM: Changed to NONE to test the shelflife)
		EMC_OverworldStatesMngr.WaterState.CLEAN, _upgrades)
	
	$GUI/VBC/MiddleSection/BackpackGUI.setup(_backpack,$Avatar, "Rucksack", true)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	#GUIs initial verstecken
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.visible = false
	$GUI/VBC/MiddleSection/EndGameGUI.visible = false
	$GUI/VBC/MiddleSection/PopUpGUI.visible = false
	$GUI/VBC/LowerSection/RestGUI.visible = false
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
	$GUI/VBC/MiddleSection/RainwaterBarrelGUI.setup(_overworld_states_mngr, _backpack)

	$StageMngr.setup(self, $Avatar, $GUI/VBC/UpperSection/HBC/DayMngr, $GUI/VBC/LowerSection/TooltipGUI, \
		$GUI/VBC/LowerSection/ChangeStageGUI)

	var seodGUI := $GUI/VBC/MiddleSection/SummaryEndOfDayGUI
	var egGUI := $GUI/VBC/MiddleSection/EndGameGUI
	var puGUI := $GUI/VBC/MiddleSection/PopUpGUI
	var action_guis : Array[EMC_ActionGUI] = []
	#MRM: Because I reworked the node structure of the GUI node, following code
	#needs to be reworked. For now I'll hardcode it.
	#for uncast in uncast_guis:
		#if uncast is EMC_ActionGUI:
			#uncast.opened.connect(_on_action_GUI_opened)
			#uncast.closed.connect(_on_action_GUI_closed)
			#guis.append(uncast as EMC_ActionGUI)
	action_guis.append($"GUI/VBC/LowerSection/RestGUI" as EMC_ActionGUI)
	action_guis.append($"GUI/VBC/LowerSection/ChangeStageGUI" as EMC_ActionGUI)
	action_guis.append($"GUI/VBC/MiddleSection/CookingGUI" as EMC_ActionGUI)
	action_guis.append($"GUI/VBC/MiddleSection/RainwaterBarrelGUI" as EMC_ActionGUI)
	
	_crisis_mngr.setup(_overworld_states_mngr,3,3)
	$GUI/VBC/UpperSection/HBC/DayMngr.setup($Avatar, _overworld_states_mngr, _crisis_mngr, action_guis, \
		$GUI/VBC/LowerSection/TooltipGUI, seodGUI, egGUI, puGUI, _backpack)
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.setup($Avatar, _backpack, $GUI/VBC/MiddleSection/BackpackGUI)
	
	


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleGUI"): #G key
		var guielem := $GUI/VBC/LowerSection
		guielem.visible = !guielem.visible
		$GUI/VBC/MiddleSection.visible = !$GUI/VBC/UpperSection.visible


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch && event.pressed == true):
		if $GUI/VBC/MiddleSection/BackpackGUI.visible: #&& !$BtnBackpack.is_pressed():
			$GUI/VBC/MiddleSection/BackpackGUI.close()


func _on_summary_end_of_day_gui_opened() -> void:
	get_tree().paused = true


func _on_summary_end_of_day_gui_closed() -> void:
	get_tree().paused = false


func _on_action_GUI_opened() -> void:
	get_tree().paused = true


func _on_action_GUI_closed() -> void:
	get_tree().paused = false


###################################### DIALOGUE HANDLING ###########################################
func _on_stage_mngr_dialogue_initiated(p_NPC_name: String) -> void:
	var dialogue_resource: DialogueResource
	#Theoretically the game is paused so no other DialogueGUI should be instantiated,
	#but for robustness we still make sure there's at most one DialogueGUI
	for node:Node in $GUI/VBC/LowerSection.get_children():
		if node.get_name() == "DialogueGUI":
			return

	#Dialogue GUI can't be instantiated in editor, because it eats up all mouse input,
	#even when it's hidden! :(
	#Workaround: Just instantiate it when needed. It's done the same way in the example code
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	dialogue_GUI.setup(_stage_mngr.get_dialogue_pitches())
	$GUI/VBC/LowerSection.add_child(dialogue_GUI)
	#MRM: Problems with load on mobile export, so I preload it for now:
	#dialogue_resource = load("res://res/dialogue/" + p_NPC_name + ".dialogue")
	match p_NPC_name:
		"Gerhard": dialogue_resource = GERHARD_DIALOG
		"Julia": dialogue_resource = JULIA_DIALOG
		"Friedel": dialogue_resource = FRIEDEL_DIALOG
		_: printerr("unknown NPC")
	dialogue_GUI.start(dialogue_resource, "start")
	get_tree().paused = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	get_tree().paused = false


func _on_backpack_gui_closed() -> void:
	_backpack_btn.set_pressed(false)
