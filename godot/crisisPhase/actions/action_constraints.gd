extends Node
class_name EMC_ActionConstraints

const NO_REJECTION: String = ""

var _day_mngr: EMC_DayMngr
var _overworld_states_mngr: EMC_OverworldStatesMngr


########################################## PUBLIC METHODS ##########################################
func _init(p_day_mngr: EMC_DayMngr, p_overworld_states_mngr: EMC_OverworldStatesMngr) -> void:
	_day_mngr = p_day_mngr
	_overworld_states_mngr = p_overworld_states_mngr


func constraint_cooking() -> String:
	#TODO: Electricity?
	##TODO: In the future: Else Gaskocher?
	return "Grund warum kochen nicht möglich ist."
	#else:
	return NO_REJECTION


func constraint_rainwater_barrel() -> String:
	if _overworld_states_mngr.get_furniture_state(_overworld_states_mngr.Furniture.RAINWATER_BARREL) == 0:
		return "Die Regentonne ist leer"
	else:
		return NO_REJECTION


func constraint_not_morning() -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.MORNING:
		return "Man kann diese Aktion nicht morgens ausführen!"
	else:
		return NO_REJECTION


func constraint_not_noon() -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.NOON:
		return "Man kann diese Aktion nicht mittag ausführen!"
	else:
		return NO_REJECTION


func constraint_not_evening() -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING:
		return "Man kann diese Aktion nicht abends ausführen!"
	else:
		return NO_REJECTION
