extends Action

func _init():
	ACTION_NAME = "normal_speed"
	constrains = {"day_time_greater": 0}
	changes = {"set_player_speed": 300.0}
	
func _on_button_pressed():
	interacted.emit(constrains, changes)
