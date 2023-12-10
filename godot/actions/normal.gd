extends Action

func _init():
	ACTION_NAME = "normal_action"
	constrains = {"day_time_greater": -1}
	changes = {"player_speed_set": 300.0}
	
func _on_button_pressed():
	interacted.emit(constrains, changes)

@onready var sprite_2d = $Sprite2D
@onready var canvas_layer = $CanvasLayer

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if sprite_2d.get_rect().has_point(sprite_2d.to_local(event.position)):
			## Only open pop up when avatar is near the interactible
			if true: #sprite_2d.get_rect().grow(500).has_point(sprite_2d.to_local(get_avatar_rect.call().position)):
				canvas_layer.show()
		else:
			canvas_layer.hide()
