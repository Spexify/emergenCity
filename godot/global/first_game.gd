extends Control
class_name EMC_FirstGame


func _on_start_tutorial_pressed() -> void:
	#Global.goto_scene("res://GUI/avatar_selection_GUI.tscn")
	## TODO: add avatar selection and starting in the middle of the crisis
	Global.load_game()
	Global.set_crisis_difficulty()
	Global._tutorial_done = true
	var start_scene_name : String = Global.CRISIS_PHASE_SCENE
	Global.goto_scene(start_scene_name)
	close()

func close() -> void:
	#get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	$CanvasModulate.hide()
	#closed.emit()
