extends Control

@onready var _settings := SettingsGUI #$"../Settings"
@onready var e_coins := $CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer/eCoins
#@onready var timer := $"../Timer"


#MRM: Added this, because there was a bug (see commit)
func open() -> void: 
	#get_tree().paused = true
	$".".show()
	$CanvasLayer_unaffectedByCM.show()
	$CanvasModulate.show()
	#opened.emit()


#MRM: Added this, because there was a bug (see commit)
func close() -> void:
	#get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	$CanvasModulate.hide()
	#closed.emit()


func _ready() -> void:
	e_coins.text = str(Global.get_e_coins())
	_settings.closed.connect(open)


func _on_start_round_pressed() -> void:
	Global.goto_scene("res://preparePhase/crisis_start.tscn")
	

func _on_shelf_pressed() -> void:
	Global.goto_scene("res://preparePhase/shop.tscn")


func _on_upgrade_center_pressed() -> void:
	pass 
	# Todo: link Upgrade Center Scene
	# get_tree().change_scene_to_file()

# var settings_scene = preload("res://preparePhase/settings.tscn")


func _on_settings_pressed() -> void:
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	#_settings.show()
	#MRM: Had a bug (see commit)
	close()
	SettingsGUI.open()
	#Global.goto_scene("res://global/settings_GUI.tscn")
	#MRM: Don't get why this is necessary, but it won't open up reliably without this:
	#for child: Node in _settings.get_children():
		#child.show()


func _on_reset_pressed() -> void:
	Global.reset_save()


func _on_information_pressed() -> void:
	Global.goto_scene("res://preparePhase/information.tscn")


func _on_credit_screen_pressed() -> void:
	Global.goto_scene("res://preparePhase/credit_information.tscn")
