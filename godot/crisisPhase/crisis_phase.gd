extends Node2D


const GERHARD_DIALOG : DialogueResource = preload("res://res/dialogue/gerhard.dialogue")
const JULIA_DIALOG : DialogueResource = preload("res://res/dialogue/julia.dialogue")
const FRIEDEL_DIALOG : DialogueResource = preload("res://res/dialogue/friedel.dialogue")
const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")

var _backpack: EMC_Inventory = Global.get_inventory()

var _overworld_states_mngr: EMC_OverworldStatesMngr = EMC_OverworldStatesMngr.new()

@onready var uncast_guis := $GUI.get_children()
@export var dialogue_resource: DialogueResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.was_crisis():
		####################LOAD SAVE STATE#######################
		Global.load_state()
		
	#TODO: Upgrades should later be initialized and passed by the UpgradeCenter
	var _upgrades: Array[EMC_OverworldStatesMngr.Furniture] = [EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL]
	_overworld_states_mngr.setup(EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, EMC_OverworldStatesMngr.WaterState.CLEAN, _upgrades)
	
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

	$StageMngr.setup($Avatar, $GUI/VBC/UpperSection/HBC/DayMngr, $GUI/VBC/LowerSection/TooltipGUI, \
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
	$GUI/VBC/UpperSection/HBC/DayMngr.setup($Avatar, _overworld_states_mngr, action_guis, \
		$GUI/VBC/LowerSection/TooltipGUI, seodGUI, egGUI, puGUI)
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.setup($Avatar, _backpack, $GUI/VBC/MiddleSection/BackpackGUI)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ToggleGUI"): #G key
		var guielem := $GUI/VBC/LowerSection
		guielem.visible = !guielem.visible
		$GUI/VBC/MiddleSection.visible = !$GUI/VBC/UpperSection.visible


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


###################################### DIALOGUE HANDLING ###########################################
func _on_stage_mngr_dialogue_initiated(p_NPC_name: String) -> void:
	#Theoretically the game is paused so no other DialogueGUI should be instantiated,
	#but for robustness we still make sure there's at most one DialogueGUI
	for node:Node in $GUI/VBC/LowerSection.get_children():
		if node.get_name() == "DialogueGUI":
			return

	#Dialogue GUI can't be instantiated in editor, because it eats up all mouse input,
	#even when it's hidden! :(
	#Workaround: Just instantiate it when needed. It's done the same way in the example code
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
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
