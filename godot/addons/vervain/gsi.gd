extends Node
class_name VRV_GSI

## GSI stands for Game Script Interface.
## The name is inspiered by API

var method_cache: Dictionary = {}
func _init() -> void:
	for dict in get_method_list():
		var args: Array
		for arg: Dictionary in dict["args"]:
			args.append(arg["type"])
		
		method_cache[dict["name"]] = {
			"args": args,
			"return": dict["return"]
		}

func get_method_signature(method_name: String) -> Dictionary:
	return method_cache[method_name]
	
func call_method(method_name: String, args: Array) -> Variant:
	return callv(method_name, args)
	
func has_method_name(method_name: String) -> bool:
	return method_cache.has(method_name)

func add(a: int, b: int) -> int:
	return a + b

func int_to_string(v: int) -> String:
	return String.num(v)

func output(stuff: String) -> String:
	print(stuff)
	return stuff
