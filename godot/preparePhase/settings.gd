extends CenterContainer

@onready var margin_container := $MarginContainer
@onready var font_change := $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/FontChange

var is_dyslexic := true
var dyslexic_font := preload("res://res/fonts/Dyslexic-Regular-Variation.tres")
var normal_font := preload("res://res/fonts/Gugi-Regular-Variation.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_dyslexic = theme.get_default_font() == dyslexic_font
	font_change.set_pressed_no_signal(is_dyslexic)

func _on_font_change_pressed() -> void:
	if (is_dyslexic):
		theme.set_default_font(normal_font)
	else:
		theme.set_default_font(dyslexic_font)
	
	is_dyslexic = !is_dyslexic
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !Rect2(margin_container.position, margin_container.get_child(0).size).has_point(event.position):
			self.hide()
	
