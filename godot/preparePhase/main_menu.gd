extends Control

var crisis_scene = preload("res://levels/crisis_phase.tscn")

@onready var main_menu = $".."
@onready var main = get_node("/root/main")

func _ready():
	if main == null:
		print("The main node could not be found. 
		This may be because you ran the main menu scene directly!")

func _on_start_round_pressed():
	if main != null:
		main.remove_child(main_menu)
		main_menu.call_deferred("free")
		main.add_child(crisis_scene.instantiate())
	else:
		get_tree().change_scene_to_file("res://levels/crisis_phase.tscn")
	

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
