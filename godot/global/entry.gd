extends Node

func _ready() -> void:
	Global.load_game()
	var start_scene_name : String = Global.load_scene_name()
	Global.goto_scene(start_scene_name)
