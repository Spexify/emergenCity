extends EMC_GUI
class_name EMC_EndGameGUI

signal opened
signal closed

@onready var open_gui_sfx = $SFX/OpenGUISFX
@onready var close_gui_sfx = $SFX/CloseGUISFX
@onready var button_sfx = $SFX/ButtonSFX

var history : Array [EMC_DayCycle]

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

## opens summary end of day GUI/makes visible
func open(p_history: Array[EMC_DayCycle], avatar_life_status : bool):
	if avatar_life_status == false :
		$LoserScreen.visible = true
		$WinnerScreen.visible = false
	else: 
		$LoserScreen.visible = false
		$WinnerScreen.visible = true
	history = p_history
	open_gui_sfx.play()
	visible = true
	opened.emit()

## closes summary end of day GUI/makes invisible
func close():
	close_gui_sfx.play()
	visible = false
	closed.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_main_menu_pressed():
	button_sfx.play()
	await button_sfx.finished
	Global.goto_scene("res://preparePhase/main_menu.tscn")
