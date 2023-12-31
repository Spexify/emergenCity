extends Node

func _ready() -> void:
	var start_scene_name : String = Global.load_scene_name()
	Global.goto_scene(start_scene_name)
