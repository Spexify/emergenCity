extends PopupPanel

signal opened
signal closed

## tackle visibility
func toggleVisibility() -> void:
	if visible == false:
		open()
	else:
		close()

## opens summary end of day GUI/makes visible
func open():
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
