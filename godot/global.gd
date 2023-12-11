extends Node

var current_scene : Node = null

@onready var root = get_tree().root

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

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
