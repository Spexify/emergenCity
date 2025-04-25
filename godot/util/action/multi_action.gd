extends EMC_Action_v2
class_name EMC_Multi_Action

const AND := "and"
const ARRAY := "array"
const OR := "or"

var exes: Array[EMC_Action_v2]
var acc: String = ARRAY

func _init(data : Dictionary, get_exe: Callable) -> void:
	if not data.has("acc"):
		print_debug("Missing Accumulator")
	else:
		acc = data["acc"]
	
	for action: Dictionary in data.get("actions"):
		if typeof(action) != TYPE_DICTIONARY:
			continue
		
		var type: String = action.get("type", "")
		if type != "":
			var res: Variant = Preloader.get_resource("res://util/action/" + type + "_action.gd")
			if res == null:
				res = ResourceLoader.load("res://util/action/" + type + "_action.gd")
				
			exes.append(res.new(action, get_exe))
		
func execute() -> Variant:
	if acc == AND:
		var result := true
		for exe : EMC_Action_v2 in exes:
			var r: Variant = exe.execute()
			if r != null:
				result &= r
		return result
	elif acc == OR:
		for exe : EMC_Action_v2 in exes:
			var r: Variant = exe.execute()
			if r != null and r:
				return true
		return false
	elif acc == ARRAY:
		var result := []
		for exe : EMC_Action_v2 in exes:
			var r: Variant = exe.execute()
			if r != null:
				result.append(r)
		return result
	return null
