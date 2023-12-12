extends Control

@onready var main_menu = $".."

func _on_start_round_pressed():
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")
	

func _on_shelf_pressed():
	pass 
	# Todo: link Shelf Scene
	# get_tree().change_scene_to_file()


func _on_upgrade_center_pressed():
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()

# var settings_scene = preload("res://preparePhase/settings.tscn")

@onready var settings = $"../Settings"

func _on_settings_pressed():
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	settings.show()
	for child in settings.get_children():
		child.show()
