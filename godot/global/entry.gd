extends Node

func _ready() -> void:
	JsonMngr.load_items()
	JsonMngr.load_pop_up_actions()
	Global.load_game()
	var start_scene_name : String = Global.load_scene_name()
	Global.goto_scene(start_scene_name)
