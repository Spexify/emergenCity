extends EMC_App

@export var handy : EMC_Handy
@export var down_texture : Texture2D

@onready var apps : GridContainer = $Window/Margin/Apps

func _ready() -> void:
	for app : EMC_App_Icon in apps.get_children():
		app.open_app.connect(_on_app_clicked, CONNECT_ONE_SHOT)
		var down : Sprite2D = Sprite2D.new()
		down.set_texture(down_texture)
		down.set_scale(Vector2(4, 4))
		down.set_position(Vector2(64, 64))
		app.add_child(down)
		
func _on_app_clicked(app_name : String) -> void:
	for app : EMC_App_Icon in apps.get_children():
		if app.app == app_name:
			var down : Sprite2D = app.get_child(2)
			app.remove_child(down)
			down.queue_free()
			apps.remove_child(app)		
			handy.add_app_icon(app)
			return
