extends Control


func _on_continue_pressed() -> void:
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)


func _on_reset_pressed() -> void:
	Global.reset_state()
	Global.reset_inventory()
	Global.reset_upgrades_equipped()
	Global.goto_scene(Global.PREPARE_PHASE_SCENE)
