extends CenterContainer

var is_dyslexic = true
var dyslexic_font = preload("res://fonts/OpenDyslexic-Regular.otf")
var normal_font = preload("res://fonts/Gugi-Regular.ttf")

@onready var ui = get_child(0)
@onready var button = get_child(0).get_child(0).get_child(0).get_child(0).get_child(2)

# Called when the node enters the scene tree for the first time.
func _ready():
	is_dyslexic = theme.get_default_font() == dyslexic_font
	button.set_pressed_no_signal(is_dyslexic)

func _on_font_change_pressed():
	if (is_dyslexic):
		theme.set_default_font(normal_font)
	else:
		theme.set_default_font(dyslexic_font)
	
	is_dyslexic = !is_dyslexic
	
func _input(event):
	if event is InputEventMouseButton:
		if !Rect2(ui.position, ui.get_child(0).size).has_point(event.position):
			get_parent().remove_child(self)
	
