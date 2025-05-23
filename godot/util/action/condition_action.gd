extends EMC_Action
class_name EMC_Condition_Action

var cond: EMC_Action
var if_exe: EMC_Action
var else_exe: EMC_Action

## Format:
##NAME {
##	"type": "condition",
##	"cond": ACTION,
##	"if": ACTION,
##	"else": ACTION
##}
## If NAME starts with an "!", the condition will be evaluated during the supply
## ACTION represents any other action
func _init(data : Dictionary) -> void:
	if not data.has_all(["cond", "if", "else"]):
		print_debug("Missing Dictionary entries")
	
	var type: String = data["cond"].get("type", "")
	if type != "":
		cond = _load_helper(type, data["cond"])
	else:
		print_debug("Cond invalid type")
		
	type = data["if"].get("type", "")
	if type != "":
		if_exe = _load_helper(type, data["if"])
	else:
		print_debug("If invalid type")
		
	type = data["else"].get("type", "")
	if type != "":
		else_exe = _load_helper(type, data["else"])
	else:
		print_debug("Else invalid type")

func set_comp(get_exe: Callable) -> void:
	cond.set_comp(get_exe)
	if_exe.set_comp(get_exe)
	else_exe.set_comp(get_exe)

func execute() -> Variant:
	if cond.execute():
		return if_exe.execute()
	else:
		return else_exe.execute()

func pre_cond() -> bool:
	return cond.execute()

func _load_helper(type : String, data: Dictionary) -> EMC_Action:
	var res: Variant = Preloader.get_resource("res://util/action/" + type + "_action.gd")
	assert(res != null, "Resource with path: res://util/action/" + type + "_action.gd not found!")
	return res.new(data)
	
