extends Node

var current_scene : Node = null

@onready var root = get_tree().root

var _e_coins : int = 10;

const MAX_ECOINS = 99999

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
	if e_coins < 0 or e_coins > MAX_ECOINS:
		return false
	_e_coins = e_coins

func add_e_coins(e_coins : int):
	if _e_coins + e_coins > MAX_ECOINS:
		_e_coins = MAX_ECOINS
	else:
		_e_coins += e_coins
	
func sub_e_coins(e_coins : int):
	if _e_coins - e_coins < 0 or e_coins < 0:
		return false
	else:
		_e_coins -= e_coins
