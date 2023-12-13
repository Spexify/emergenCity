extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

signal opened
signal closed

## tackle visibility
# MRM: This function would be a bonus, but since the open function expects a parameter I commented
# it out.
#func toggleVisibility() -> void:
	#if visible == false:
		#open()
	#else:
		#close()

## opens summary end of day GUI/makes visible
func open(p_day_cycle: EMC_DayCycle):
	visible = true
	opened.emit()

## closes summary end of day GUI/makes invisible
func close():
	visible = false
	closed.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_continue_pressed():
	close()
	pass # Replace with function body.


func _on_new_day_pressed():
	pass # Replace with function body.
