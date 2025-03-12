extends EMC_Action_v2
class_name EMC_Condition_Action

var cond: EMC_Action_v2
var if_exe: EMC_Action_v2
var else_exe: EMC_Action_v2

func _init(data : Dictionary, get_exe: Callable) -> void:
	if not data.has_all(["cond", "if", "else"]):
		print_debug("Missing Dictionary entries")
	
	var type: String = data["cond"].get("type", "")
	if type != "":
		cond = _load_helper(type, data["cond"], get_exe)
	else:
		print_debug("Cond invalid type")
		
	type = data["if"].get("type", "")
	if type != "":
		if_exe = _load_helper(type, data["if"], get_exe)
	else:
		print_debug("If invalid type")
		
	type = data["else"].get("type", "")
	if type != "":
		else_exe = _load_helper(type, data["else"], get_exe)
	else:
		print_debug("Else invalid type")
		
func execute() -> Variant:
	if cond.execute():
		return if_exe.execute()
	else:
		return else_exe.execute()

func _load_helper(type : String, data: Dictionary, parent: Variant) -> EMC_Action_v2:
	var res: Variant = Preloader.get_resource("res://util/action/" + type + "_action.gd")
	assert(res != null, "Resource with path: res://util/action/" + type + "_action.gd not found!")
	return res.new(data, parent)
	
