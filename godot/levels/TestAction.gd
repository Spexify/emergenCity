extends Action

func _init():
	ACTION_NAME = "slow_speed"
	constrains = {"day_time_equal": 0}
	changes = {"set_player_speed": 100.0}
	
func _on_button_pressed():
	interacted.emit(constrains, changes)
