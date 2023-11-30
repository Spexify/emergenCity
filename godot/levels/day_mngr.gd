extends Node

class_name EMC_DayMngr

var history : Array[EMC_DayCycle]
var current_day_cycle : EMC_DayCycle

enum EMC_DayPeriod {MORNING = 0, NOON = 1, EVENING = 2}

var day_period : EMC_DayPeriod = EMC_DayPeriod.MORNING
var current_day : int = 0
var max_day : int

var actions : Array[EMC_Action]

var ui_refs : Array[Callable]
var summary_end_of_day_ref : Callable
var end_of_game_ref : Callable

func setup(ui_refs, max_day : int = 3):
	self.max_day = max_day
	self.ui_refs = ui_refs
	
	actions.append(EMC_Action.new("test_action", {"test_constrain" : 0}, 
								 {"test_change" : 0}, "test_ui", 
								 "This is a Test Action"))


func _on_furniture_clicked(action_id : int, stage_name : String):
	var current_action : EMC_Action = self.actions[action_id]
	
	var rejected_constrains : Array[String] = []
	for constrain_key in current_action.constrains_prior.keys():
		if not Callable(self, constrain_key).call(current_action.constrains_prior[constrain_key]):
			rejected_constrains.append(constrain_key)
	
	if rejected_constrains.size() >= 1:
		self.ui_refrences[0].call(current_action)
	else:
		pass

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
