extends Node

var current_scene : Node = null

@onready var root = get_tree().root

var _e_coins : int = 0;

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()

	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	root.add_child(current_scene)

func load_scene_name():
	return "res://preparePhase/main_menu.tscn"
	
func save():
	pass

func get_e_coins():
	return _e_coins
	
func set_e_coins(e_coins : int):
	if e_coins < 0:
		return false
	else:
		_e_coins = e_coins

func add_e_coins(e_coins : int):
	_e_coins += e_coins
	
func sub_e_coins(e_coins : int):
	if _e_coins - e_coins < 0:
		return false
	else:
		_e_coins -= e_coins
