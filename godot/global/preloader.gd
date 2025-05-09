extends Node
class_name EMC_Preloader

const pre_resources: Dictionary = {
	"res://util/action/condition_action.gd" : preload("res://util/action/condition_action.gd"),
	"res://util/action/multi_action.gd" : preload("res://util/action/multi_action.gd"),
	"res://util/action/single_action.gd" : preload("res://util/action/single_action.gd"),
}

var resources: Dictionary = {}

#func get_resource(path: String) -> Resource:
	#if pre_resources.has(path):
		#return pre_resources[path]
		#
	#if not resources.has(path):
		#resources[path] = ResourceLoader.load(path)
	#return resources[path]

func get_resource(path: String) -> Resource:
	return ResourceLoader.load(path)
