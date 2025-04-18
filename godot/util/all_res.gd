extends Resource
class_name EMC_AllRes

@export var data: Dictionary
 
func add_res(p_name: String, p_data: Variant) -> void:
	data[p_name] = p_data

func get_res(p_name: String) -> Variant:
	return data.get(p_name, null)
