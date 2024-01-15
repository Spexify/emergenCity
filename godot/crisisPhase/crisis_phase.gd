extends Node2D

var _backpack: EMC_Inventory = Global.get_inventory()

const _DIALOGUE_GUI_SCN: PackedScene = preload("res://GUI/dialogue_GUI.tscn")

@onready var uncast_guis := $GUI.get_children()
@onready var dialogue_GUI := $GUI/VBC/LowerSection/DialogueGUI
@export var dialogue_resource: DialogueResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.was_crisis():
		####################LOAD SAVE STATE#######################
		Global.load_state()
	
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
	#dialogue_GUI.hide()
	
	#Setup-Methoden
	$GUI/VBC/LowerSection/ChangeStageGUI.setup($StageMngr, $Avatar)
	$GUI/VBC/LowerSection/RestGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/LowerSection/RestGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/LowerSection/ChangeStageGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/LowerSection/ChangeStageGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/MiddleSection/PopUpGUI.opened.connect(_on_action_GUI_opened)
	$GUI/VBC/MiddleSection/PopUpGUI.closed.connect(_on_action_GUI_closed)
	$GUI/VBC/MiddleSection/CookingGUI.setup(_backpack)
	
	$StageMngr.setup($Avatar, $GUI/VBC/UpperSection/HBC/DayMngr, $CityMap)
	$CityMap.setup($GUI/VBC/UpperSection/HBC/DayMngr, $StageMngr, $GUI/VBC/LowerSection/TooltipGUI)
	
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
	#TODO: Substitute null with OptionalEventMngr:
	$GUI/VBC/UpperSection/HBC/DayMngr.setup($Avatar, null, action_guis, \
		$GUI/VBC/LowerSection/TooltipGUI, seodGUI, egGUI, puGUI) 
	$GUI/VBC/MiddleSection/SummaryEndOfDayGUI.setup($Avatar, _backpack)
	
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
	#var existing_GUI = $GUI/VBC/LowerSection.get_node("DialogueGUI")
	for node:Node in $GUI/VBC/LowerSection.get_children():
		if node.get_name() == "DialogueGUI":
			return #We don't want to start a new Dialogue if an old one is still going
	
	#Dialogue GUI can't be instantiated in editor, because it eats up all mouse input,
	#even when it's hidden! :(
	#Workaround: Just instantiate it when needed. It's done the same way in the example code
	var dialogue_GUI: EMC_DialogueGUI = _DIALOGUE_GUI_SCN.instantiate()
	$GUI/VBC/LowerSection.add_child(dialogue_GUI)
	dialogue_resource = load("res://res/dialogue/" + p_NPC_name + ".dialogue")
	dialogue_GUI.start(dialogue_resource, "start")
	get_tree().paused = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	print("Dialogue ended...")
	get_tree().paused = false
	pass
