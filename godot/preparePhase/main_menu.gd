extends Control

@onready var open_guisfx := $"../SFX/OpenGUISFX"
@onready var close_guisfx := $"../SFX/CloseGUISFX"
@onready var button_sfx := $"../SFX/ButtonSFX"
@onready var e_coins := $MarginContainer/eCoins
#@onready var timer := $"../Timer"

func _ready() -> void:
	e_coins.text = str(Global.get_e_coins()) + " eCoins"

func _on_start_round_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://crisisPhase/crisis_phase.tscn")
	

func _on_shelf_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://preparePhase/shop.tscn")


func _on_upgrade_center_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()

# var settings_scene = preload("res://preparePhase/settings.tscn")

@onready var settings := $"../Settings"

func _on_settings_pressed() -> void:
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	button_sfx.play()
	await button_sfx.finished
	settings.show()
	for child in settings.get_children():
		child.show()


func _on_reset_pressed() -> void:
	Global.reset_save()
