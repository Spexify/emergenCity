extends Control

@onready var _settings := SettingsGUI #$"../Settings"
@onready var e_coins := $CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer/eCoins
#@onready var timer := $"../Timer"


#MRM: Added this, because there was a bug (see commit)
func open() -> void: 
	#get_tree().paused = true
	$".".show()
	$CanvasLayer_unaffectedByCM.show()
	$CanvasModulate.show()
	
	#opened.emit()


#MRM: Added this, because there was a bug (see commit)
func close() -> void:
	#get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	$CanvasModulate.hide()
	#closed.emit()


func _ready() -> void:
	e_coins.text = str(Global.get_e_coins())
	_settings.closed.connect(open)
	if !Global._tutorial_done:
		$CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer.hide()
		$CanvasLayer_unaffectedByCM/MarginContainer2.hide()
		$CanvasLayer_unaffectedByCM/InformationButtons.hide()
		$CanvasLayer_unaffectedByCM/VBoxContainerNormal/CenterContainerNormal/GameButtons/Shelf.hide()
		$CanvasLayer_unaffectedByCM/VBoxContainerNormal/CenterContainerNormal/GameButtons/UpgradeCenter.hide()


func _on_start_round_pressed() -> void:
	if !Global._tutorial_done:
		close()
		$"../AvatarSelectionGUI".open(true)
	else: 
		Global.goto_scene("res://preparePhase/crisis_start.tscn")
	

func _on_shelf_pressed() -> void:
	Global.goto_scene("res://preparePhase/shop.tscn")


func _on_upgrade_center_pressed() -> void:
	Global.goto_scene("res://preparePhase/upgrade_center.tscn")
	# Todo: link Upgrade Center Scene
	#get_tree().change_scene_to_file("res://preparePhase/upgrade_center.tscn")

# var settings_scene = preload("res://preparePhase/settings.tscn")


func _on_settings_pressed() -> void:
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	#_settings.show()
	#MRM: Had a bug (see commit)
	close()
	SettingsGUI.open()
	#Global.goto_scene("res://global/settings_GUI.tscn")
	#MRM: Don't get why this is necessary, but it won't open up reliably without this:
	#for child: Node in _settings.get_children():
		#child.show()


func _on_reset_pressed() -> void:
	Global.reset_save()


func _on_information_pressed() -> void:
	Global.goto_scene(Global.INFORMATION_SCENE)


func _on_credit_screen_pressed() -> void:
	Global.goto_scene(Global.CREDIT_SCENE)


func _on_avatar_selection_gui_closed() -> void:
	Global.load_game()
	OverworldStatesMngr.set_crisis_difficulty("Tutorial Scenario", EMC_OverworldStatesMngr.WaterState.CLEAN, EMC_OverworldStatesMngr.ElectricityState.NONE,
							EMC_OverworldStatesMngr.IsolationState.NONE, EMC_OverworldStatesMngr.FoodContaminationState.NONE,
							3, 1, "Das ist die erste Krise seit langem! Es gab einen regionalen Stromausfall!")
	OverworldStatesMngr._set_all_states(EMC_OverworldStatesMngr.WaterState.CLEAN, EMC_OverworldStatesMngr.IsolationState.NONE,
										EMC_OverworldStatesMngr.FoodContaminationState.NONE, EMC_OverworldStatesMngr.ElectricityState.NONE,)
	var start_scene_name : String = Global.CRISIS_PHASE_SCENE
	Global.goto_scene(start_scene_name)
	close()
