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
