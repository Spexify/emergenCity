extends Node

func _ready() -> void:
	OS.request_permission("android.permission.MANAGE_EXTERNAL_STORAGE")
	
	Global.set_started_from_entry_scene()
	JsonMngr.load_items()
	JsonMngr.load_upgardes()
	JsonMngr.load_opt_events()
	JsonMngr.load_actions()
	JsonMngr.load_scenarios()
	JsonMngr.load_crisis()
	JsonMngr.load_dialogues()
	Global.load_game()
	var start_scene_name : String = Global.load_scene_name()
	Global.goto_scene(start_scene_name)
