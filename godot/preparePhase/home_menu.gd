extends Control

func _on_start_round_pressed():
	get_tree().change_scene_to_file("res://levels/crisis_phase.tscn")


func _on_shelf_pressed():
	pass 
	# Todo: link Shelf Scene
	# get_tree().change_scene_to_file()


func _on_upgrade_center_pressed():
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()
