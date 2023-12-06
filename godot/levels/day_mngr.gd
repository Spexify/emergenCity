extends Node

class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constrains_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

var history : Array[EMC_DayCycle]
var current_day_cycle : EMC_DayCycle

## Enum describing the periods of a Day.
enum EMC_DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

var day_period : EMC_DayPeriod = EMC_DayPeriod.MORNING
var current_day : int = 0
var max_day : int

var _actionArr : Array[EMC_Action]

var gui_refs : Array[EMC_GUI]
var summary_end_of_day_ref : Callable
var end_of_game_ref : Callable

func _ready():
	_actionArr.append(EMC_Action.new("test_action", {"test_constrain" : 0}, 
								 {"test_change" : 0}, "test_ui", 
								 "This is a Test Action"))

func setup(gui_refs : Array[EMC_GUI], max_day : int = 3):
	self.max_day = max_day
	self.gui_refs = gui_refs

func on_interacted_with_furniture(action_id : int):
	var current_action : EMC_Action = self._actionArr[action_id]
	
	var rejected_constrains : Array[String] = []
	for constrain_key in current_action._constrains_prior.keys():
		if not Callable(self, constrain_key).call(current_action._constrains_prior[constrain_key]):
			rejected_constrains.append(constrain_key)
	
	if rejected_constrains.size() >= 1:
		current_action._constrains_rejected = rejected_constrains
		if self.gui_refs[0].get_type_gui() == "reject":
			self.gui_refs[0].show_gui(current_action)
		else:
			_get_gui_ref_by_name("reject").show_gui(current_action)
	else:
		_get_gui_ref_by_name(current_action.type_ui).show_gui(current_action)

func _get_gui_ref_by_name(name : String) -> EMC_GUI:
	for ref in self.gui_refs:
		if ref.get_type_gui() == name:
			return ref
	return null
	
func _on_executed(action : EMC_Action):
	self.day_period += 1
	self.current_day = self.day_period % 3
	
	match self.day_period:
		EMC_DayPeriod.MORNING:
			self.current_day_cycle = EMC_DayCycle.new()
			self.current_day_cycle.morning_action = action
		EMC_DayPeriod.NOON:
			self.current_day_cycle.noon_action = action
		EMC_DayPeriod.EVENING:
			self.current_day_cycle.evening_action = action
			self.history.append(self.current_day_cycle)
			self.summary_end_of_day_ref.call(self.history)
	
	if self.current_day >= self.max_day:
		self.end_of_game_ref.call(self.current_day_cycle)
		
func get_current_day_cycle():
	return self.current_day_cycle
	
func get_current_day_preiod():
	return self.day_period

func get_current_day():
	return self.day
