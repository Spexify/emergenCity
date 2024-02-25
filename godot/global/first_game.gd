extends Control
class_name EMC_FirstGame

func _ready() -> void:
	$AnimationPlayer.play("Fade")
	await( get_tree().create_timer(2))


func _on_start_tutorial_pressed() -> void:
	close()
	$AvatarSelectionGUI.open()


func close() -> void:
	#get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	$CanvasModulate.hide()
	#closed.emit()


func _on_avatar_selection_gui_closed() -> void:
	Global.load_game()
	OverworldStatesMngr.set_crisis_difficulty(EMC_OverworldStatesMngr.WaterState.CLEAN, EMC_OverworldStatesMngr.ElectricityState.NONE,
							EMC_OverworldStatesMngr.IsolationState.NONE, EMC_OverworldStatesMngr.FoodContaminationState.NONE,
							3, 1, "Der Strom ist ausgefallen!")
	var start_scene_name : String = Global.CRISIS_PHASE_SCENE
	Global.goto_scene(start_scene_name)
	close()
