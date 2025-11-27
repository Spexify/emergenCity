extends Resource
class_name VRV_Action

@export var ast: Dictionary

func execute(gsi: VRV_GSI, context: Dictionary = {}) -> Variant:
	if ast.is_empty():
		printerr("Action: Executed empty action")
		return null
	
	return _execute_helper(ast, gsi, context)

func _execute_helper(branch: Dictionary, gsi: VRV_GSI, context: Dictionary = {}) -> Variant:
	match branch.get("type", "empty"):
		"string", "json", "array", "int", "float", "bool":
			return branch.get("value")
		"var":
			var name: String = branch.get("name", "")
			var value: Variant = context.get(name, null)
			if value == null:
				printerr("Action: Variable with name %s not in context" % name)
				return false
			return value
		"call":
			var method_name: String = branch.get("name")
			if gsi.has_method_name(method_name):
				var args: Array = []
				for arg in branch.get("args"):
					args.append(_execute_helper(arg, gsi, context))
				
				if _check_args(args, gsi.get_method_signature(method_name)["args"]):
					return gsi.call_method(method_name, args)
				return false
			else:
				printerr("Action: No method of name %s" % method_name)
				return false
		"empty":
			printerr("Action: Type not found in branch %s of action %s" % [branch, ast])
			return false
	
	printerr("Action: Unrecognised type: %s" % [branch["type"]])
	return null

func _check_args(args: Array, expected: Array) -> bool:
	if args.size() != expected.size():
		printerr("Action: Parameter count missmatch is %s expected %s" % [args.size(), expected.size()])
		return false
		
	for i: int in range(args.size()):
		if typeof(args[i]) != expected[i]:
			printerr("Action: Parameter type missmatch is %s expected %s" % [type_string(typeof(args[i])), type_string(expected[i])])
			return false
	
	return true
