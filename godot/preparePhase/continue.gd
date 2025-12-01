extends Control


func _on_continue_pressed() -> void:
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)

func _on_cancel_pressed() -> void:
	Global.save_game(Global.State.START)
	Global.load_game()
	SoundMngr.play_slow_musik()
	Global.goto_scene(Global.MAIN_MENU_SCENE)
