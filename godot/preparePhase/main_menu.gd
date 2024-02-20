extends Control

@onready var _settings := SettingsGUI #$"../Settings"
@onready var open_guisfx := $"../SFX/OpenGUISFX"
@onready var close_guisfx := $"../SFX/CloseGUISFX"
@onready var button_sfx := $"../SFX/ButtonSFX"
@onready var e_coins := $CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer/eCoins
#@onready var timer := $"../Timer"

var _tutorial_done : bool = false


#MRM: Added this, because there was a bug (see commit)
func open() -> void:
	if _tutorial_done : 
		#get_tree().paused = true
		$".".show()
		$CanvasLayer_unaffectedByCM.show()
		$CanvasModulate.show()
		$"../MenuFirstGame".hide()
		$"../MenuFirstGame/CanvasLayer_unaffectedByCM".hide()
		$"../MenuFirstGame/CanvasModulate".hide()
		#opened.emit()
	else: 
		$".".hide()
		$CanvasLayer_unaffectedByCM.hide()
		$CanvasModulate.hide()
		$"../MenuFirstGame".show()
		$"../MenuFirstGame/CanvasLayer_unaffectedByCM".show()
		$"../MenuFirstGame/CanvasModulate".show()


#MRM: Added this, because there was a bug (see commit)
func close() -> void:
	#get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	$"../MenuFirstGame/CanvasLayer_unaffectedByCM".hidE()
	$CanvasModulate.show()
	$"../MenuFirstGame/CanvasModulate".show()
	#closed.emit()


func _ready() -> void:
	e_coins.text = str(Global.get_e_coins())
	_settings.closed.connect(open)


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
