extends Control

var dyslexic_font = preload("res://fonts/OpenDyslexic-Regular.otf")

func _ready():
	theme.set_default_font(dyslexic_font)

func _on_start_round_pressed():
	pass
	# Todo: link crisis phase Scene
	# get_tree().change_scene_to_file("res://levels/crisis_phase.tscn")
	

func _on_shelf_pressed():
	pass 
	# Todo: link Shelf Scene
	# get_tree().change_scene_to_file()


func _on_upgrade_center_pressed():
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()

var settings_scene = preload("res://preparePhase/settings.tscn")

func _on_settings_pressed():
	var new_setting = settings_scene.instantiate()
	add_child(new_setting)
