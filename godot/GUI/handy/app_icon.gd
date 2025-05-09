@tool
class_name EMC_App_Icon

extends VBoxContainer

signal open_app(app : String)

@export var app : String
@export var icon : Texture2D:
	set(v):
		icon = v
		$Icon.set_texture_normal(icon)
		
@export var title : String:
	set(v):
		title = v
		$Title.set_text(title)

func _on_icon_pressed() -> void:
	open_app.emit(app) #app.start()
