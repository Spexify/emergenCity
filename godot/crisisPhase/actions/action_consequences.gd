extends Node
class_name EMC_ActionConsequences

var _avatar: EMC_Avatar


########################################## PUBLIC METHODS ##########################################
func _init(p_avatar: EMC_Avatar) -> void:
	_avatar = p_avatar


func add_health(p_value: int) -> void:
	_avatar.add_health(p_value)
