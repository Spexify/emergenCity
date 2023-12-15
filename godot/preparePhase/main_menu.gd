extends Control

@onready var open_guisfx = $"../SFX/OpenGUISFX"
@onready var close_guisfx = $"../SFX/CloseGUISFX"
@onready var button_sfx = $"../SFX/ButtonSFX"

func _on_start_round_pressed():
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")
	

func _on_shelf_pressed():
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://preparePhase/shop.tscn")


func _on_upgrade_center_pressed():
	button_sfx.play()
	await button_sfx.finished
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()

# var settings_scene = preload("res://preparePhase/settings.tscn")

@onready var settings = $"../Settings"

func _on_settings_pressed():
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	button_sfx.play()
	await button_sfx.finished
	settings.show()
	for child in settings.get_children():
		child.show()
