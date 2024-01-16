extends Control


func _on_continue_pressed() -> void:
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")


func _on_reset_pressed() -> void:
	Global.reset_save()
	Global.goto_scene("res://preparePhase/main_menu.tscn")
