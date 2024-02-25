extends Node

func _ready() -> void:
	JsonMngr.load_items()
	JsonMngr.load_pop_up_actions()
	#if !Global._tutorial_done:
		### add animation, avtar setting and being thrown in the middle of an easy crisis
		#Global.goto_scene(Global.FIRST_GAME_SCENE)
	#else:
	Global.load_game()
	var start_scene_name : String = Global.load_scene_name()
	Global.goto_scene(start_scene_name)
