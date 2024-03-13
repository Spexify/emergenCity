class_name EMC_DayCycle
## EMC_DayCycle speicherte die [EMC_Action]'s ab welche an einem Tag ausgeführt wurden.
## Note MRM: Kann eig. als "innere Klasse" von DayMngr implementiert werden
## @tutorial: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inner-classes

## [EMC_Action] preformed during [enum EMC_DayMngr.EMC_DayPeriod].MORNING
var morning_action : EMC_Action

## [EMC_Action] preformed during [enum EMC_DayMngr.EMC_DayPeriod].NOON
var noon_action : EMC_Action

## [EMC_Action] preformed during [enum EMC_DayMngr.EMC_DayPeriod].EVENING
var evening_action : EMC_Action

func save() -> Dictionary:
	var data : Dictionary = {
		"morning_action": morning_action.save() if morning_action != null else EMC_Action.empty_action().save(),
		"noon_action": noon_action.save() if noon_action != null else EMC_Action.empty_action().save(),
		"evening_action": evening_action.save() if evening_action != null else EMC_Action.empty_action().save(),
	}
	return data


func load_state(data : Dictionary) -> void:
	morning_action = EMC_Action.empty_action()
	morning_action.load_state(data.get("morning_action"))
	
	noon_action = EMC_Action.empty_action()
	noon_action.load_state(data.get("noon_action"))
	
	evening_action = EMC_Action.empty_action()
	evening_action.load_state(data.get("evening_action"))
