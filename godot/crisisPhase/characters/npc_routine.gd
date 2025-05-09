extends EMC_NPC_Idee
class_name EMC_NPC_Routine

@export var routine: Dictionary = {
	EMC_DayMngr.DayPeriod.MORNING: "stroll#",
	EMC_DayMngr.DayPeriod.NOON: "work#",
	EMC_DayMngr.DayPeriod.EVENING: "idel#"
}

@onready var npc : EMC_NPC = $"../.."

var _day_mngr: EMC_DayMngr

func _init(data: Dictionary) -> void:
	for time: String in data.get("schedule"):
		var actions: Array[String]
		if typeof(data.get("schedule")[time]) == TYPE_STRING:
			actions.assign([data.get("schedule")[time]])
		else:
			actions.assign(data.get("schedule")[time])
		routine[time.to_int() as EMC_DayMngr.DayPeriod] = actions

func _ready() -> void:
	_day_mngr = npc.get_day_mngr()
	npc.add_comp(self)

func supply_actions() -> Array[String]:
	return routine.get(_day_mngr.get_current_day_period())

func is_not_morning() -> bool:
	return not _day_mngr.get_current_day_period() == _day_mngr.DayPeriod.MORNING
