extends Control

@onready var _settings := SettingsGUI #$"../Settings"
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
	Global.goto_scene("res://preparePhase/crisis_start.tscn")
	

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


func _on_settings_pressed() -> void:
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	button_sfx.play()
	await button_sfx.finished
	_settings.show()
	#MRM: Don't get why this is necessary, but it won't open up reliably without this:
	for child: Node in _settings.get_children():
		child.show()


func _on_reset_pressed() -> void:
	Global.reset_save()


func _on_information_pressed() -> void:
	pass # Replace with function body.


func _on_credit_screen_pressed() -> void:
	pass # Replace with function body.
