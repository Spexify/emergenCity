extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

signal opened
signal closed

@onready var open_gui_sfx = $SFX/OpenGUISFX
@onready var close_gui_sfx = $SFX/CloseGUISFX
@onready var button_sfx = $SFX/ButtonSFX


var _avatar: EMC_Avatar

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

func setup(p_avatar: EMC_Avatar):
	_avatar = p_avatar

## opens summary end of day GUI/makes visible
func open(p_day_cycle: EMC_DayCycle):
	open_gui_sfx.play()
	$DecisionWindow.visible = true
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


func _on_continue_pressed():
	button_sfx.play()
	$DecisionWindow.visible = false
	$SummaryWindow.visible = true


func _on_new_day_pressed():
	button_sfx.play()
	await button_sfx.finished
	close()
