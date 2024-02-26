extends Node
class_name EMC_ActionConstraints

const NO_REJECTION: String = ""

var _day_mngr: EMC_DayMngr
var _overworld_states_mngr: EMC_OverworldStatesMngr


########################################## PUBLIC METHODS ##########################################
func _init(p_day_mngr: EMC_DayMngr, p_overworld_states_mngr: EMC_OverworldStatesMngr) -> void:
	_day_mngr = p_day_mngr
	_overworld_states_mngr = p_overworld_states_mngr


func constraint_cooking(_dummy_param: Variant) -> String:
	#TODO: Electricity?
	##TODO: In the future: Else Gaskocher?
	return "Grund warum kochen nicht möglich ist."
	#else:
	return NO_REJECTION


func constraint_rainwater_barrel(_dummy_param: Variant) -> String:
	if _overworld_states_mngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) == 0:
		return "Die Regentonne ist leer"
	else:
		return NO_REJECTION


func constraint_not_morning(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.MORNING:
		var reason := "Man kann diese Aktion nicht morgens ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_not_noon(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.NOON:
		var reason := "Man kann diese Aktion nicht mittags ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_not_evening(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING:
		var reason := "Man kann diese Aktion nicht abends ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_no_isolation(p_reason: String = "") -> String:
	if OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.IsolationState.ISOLATION:
		var reason := "Es herrscht momentan eine Isolations-Verordnung!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_some_water_available(p_reason: String = "") -> String:
	if  OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.CLEAN || \
		OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.DIRTY:
		return NO_REJECTION
	else:
		var reason := "Kein Wasser verfügbar!" if p_reason == "" else p_reason 
		return reason 
