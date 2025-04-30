extends EMC_Action_v2
class_name EMC_Single_Action

var exe: Callable
var method: String
var get_exe: Callable
var params: Array
var comp: Node = null
var comp_name: String
var comp_path: NodePath

func _init(data : Dictionary) -> void:
	if not data.has_all(["method", "params", "comp"]):
		print_debug("Missing Dictionary entries")
		
	method = data["method"]
	params = data["params"]
	comp_name = data["comp"]

func set_comp(get_exe: Callable) -> void:
	comp = get_exe.call(comp_name)
	comp_path = comp.get_path()
		
func execute() -> Variant:
	if exe.is_null() or not exe.is_valid():
		if comp == null:
			comp = Global.get_node(comp_path)
		if comp != null and comp.has_method(method):
			exe = Callable(comp, method).bindv(params)
		else:
			print_debug(comp_name + " does not have method " + method)
	
	return exe.call()
