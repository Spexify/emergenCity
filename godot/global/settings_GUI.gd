extends EMC_GUI
class_name EMC_SettingsGUI

signal avatar_sprite_changed(p_avatar_sprite_suffix: String)

@onready var font_change := $CanvasLayer/VBoxContainer/CenterContainer2/Buttons/FontChange
@onready var canvas_layer := $CanvasLayer
@onready var canvas_modulate := $CanvasModulate
@onready var sounds := $CanvasLayer/VBoxContainer/CenterContainer2/Sounds
@onready var buttons := $CanvasLayer/VBoxContainer/CenterContainer2/Buttons
@onready var music := $CanvasLayer/VBoxContainer/CenterContainer2/Sounds/Music
@onready var sfx := $CanvasLayer/VBoxContainer/CenterContainer2/Sounds/SFX
@onready var reset := $CanvasLayer/VBoxContainer/CenterContainer2/Buttons/Reset

const dyslexic_font := preload("res://res/fonts/Dyslexic-Regular-Variation.tres")
const normal_font := preload("res://res/fonts/Gugi-Regular-Variation.tres")


var is_dyslexic := false
var _avatar_sprite_suffix: String = EMC_AvatarSelectionGUI.SPRITE_NB03
signal debug_mode

#------------------------------------------ PUBLIC METHODS -----------------------------------------

func open() -> void:
	$AvatarSelectionGUI.hide()
	canvas_layer.show()
	canvas_modulate.show()
	show()
	opened.emit()

func close(without_signal : bool = false) -> void:
	hide()
	canvas_layer.hide()
	canvas_modulate.hide()
	if not without_signal:
		closed.emit()


func set_avatar_sprite_suffix(p_avatar_sprite_suffix: String) -> void:
	_avatar_sprite_suffix = p_avatar_sprite_suffix
	avatar_sprite_changed.emit(_avatar_sprite_suffix)


func get_avatar_sprite_suffix() -> String:
	return _avatar_sprite_suffix

########################################## PRIVATE METHODS #########################################

func _ready() -> void:
	is_dyslexic = theme.get_default_font() == dyslexic_font
	font_change.set_pressed_no_signal(is_dyslexic)
	close()
	
	music.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(2)))
	sfx.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(1)))


func _on_font_change_pressed() -> void:
	if (is_dyslexic):
		theme.set_default_font(normal_font)
	else:
		theme.set_default_font(dyslexic_font)
	
	is_dyslexic = !is_dyslexic


func _on_reset_pressed() -> void:
	self.close(true)
	Global.reset_state()
	Global.reset_save()
	get_tree().paused = false
	Global.goto_scene(Global.PREPARE_PHASE_SCENE)


func _on_fortsetzen_pressed() -> void:
	close()
	#MRM: Bug: The settings menu is also availbe inside the crisis phase: This doesn't allow
	#the player to close the settings, so I commented it out:
	#Global.goto_scene("res://preparePhase/main_menu.tscn") 


func _on_sound_pressed() -> void:
	buttons.hide()
	sounds.show()


func _on_back_pressed() -> void:
	buttons.show()
	sounds.hide()


func _on_select_avatar_pressed() -> void:
	#MRM: Can't call close() because the closed-Signal triggers the opening of the 
	#normal pause menue. Not a beautiful solution, but works for now, sorry:
	hide()
	canvas_layer.hide()
	$AvatarSelectionGUI.open()


func _on_avatar_selection_gui_closed() -> void:
	if canvas_layer == null: return
	show()
	canvas_layer.show()
