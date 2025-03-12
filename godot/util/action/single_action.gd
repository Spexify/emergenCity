extends EMC_Action_v2
class_name EMC_Single_Action

var exe: Callable
var method: String
var get_exe: Callable
var params: Array
var comp_name: String

func _init(data : Dictionary, p_get_exe: Callable) -> void:
	if not data.has_all(["method", "params", "comp"]):
		print_debug("Missing Dictionary entries")
	
	get_exe = p_get_exe
	method = data["method"]
	params = data["params"]
	comp_name = data["comp"]
	
		
func execute() -> Variant:
	if exe.is_null():
		var comp: Variant = get_exe.call(comp_name)
		if comp != null and comp.has_method(method):
			exe = Callable(comp, method).bindv(params)
		else:
			print_debug(comp_name + " does not have method " + method)
	
	return exe.call()

