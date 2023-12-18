extends Control

class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

## Enum describing the periods of a Day.
enum EMC_DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

var history : Array[EMC_DayCycle]
#MRM: Technically redundant: current_day_cycle = history[get_current_day()], if array initialized accordingly:
var current_day_cycle : EMC_DayCycle 

var _period_cnt : EMC_DayPeriod = EMC_DayPeriod.MORNING
#var current_day : int = 0 #MRM: Redundant: Can be deduced through period_cnt (use getters)
var max_day : int

#var _actionArr : Array[EMC_Action] #MRM: Curr not used anymore
var gui_refs : Array[EMC_ActionGUI]
var _seodGUI : EMC_SummaryEndOfDayGUI
var _egGUI : EMC_EndGameGUI
var _puGUI : EMC_PopUpGUI

var _avatar_ref : EMC_Avatar
var avatar_life_status : bool = true

var _pu_GUI_counter : int
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
const LOWER_RANGE : int = 1
const UPPER_RANGE : int = 3

func _create_action(p_action_ID: int):
	var result: EMC_Action
	match p_action_ID:
		0: #(unused)
			push_error("Action ID 0 sollte nicht erstellt werden!")
		1: result = EMC_StageChangeAction.new(p_action_ID, "Teleporter_Home", { }, 
								 "N/A", "home", Vector2i(450, 500)) #No descr, as it should never be executed
		2: result = EMC_StageChangeAction.new(p_action_ID, "Teleporter_Marketplace", { }, 
								 "Hat Marktplatz besucht.", "market", Vector2i(250, 1000))
		3: result = EMC_Action.new(p_action_ID, "Rest", { }, 
								 { }, "rest_GUI", 
								 "Hat sich ausgeruht.")
		4: result = EMC_Action.new(p_action_ID, "Cooking", {"constraint_cooking" : 0}, 
								 { }, "cooking_GUI", 
								 "Hat gekocht.")
		5: result = EMC_Action.new(p_action_ID, "Pop Up Event", { }, { }, "PopUpGUI", 
								 "Pop Up Aktion ausgeführt.")
		_: push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
	result.executed.connect(_on_action_executed)
	return result


func setup(avatar_ref : EMC_Avatar,
gui_refs : Array[EMC_ActionGUI],
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI, 
puGUI : EMC_PopUpGUI, max_day : int = 3):
	_avatar_ref = avatar_ref
	self.max_day = max_day
	self.gui_refs = gui_refs
	_seodGUI = seodGUI
	_egGUI = egGUI
	_puGUI = puGUI
	_rng.randomize()
	_pu_GUI_counter = _rng.randi_range(LOWER_RANGE,UPPER_RANGE)
	_update_HUD()


func on_interacted_with_furniture(action_id : int):
	#MRM: Duplicate of Objects cumbersome, and using the references of the array directly would
	#lead to errors. That's why I changed it, so it just creates a new instance each time:
	var current_action : EMC_Action = _create_action(action_id)
	
	var rejected_constraints : Array[String] = []
	for constrain_key in current_action.get_constraints_prior().keys():
		if not Callable(self, constrain_key).call():
			rejected_constraints.append(constrain_key)
	
	if rejected_constraints.size() >= 1:
		current_action.set_constraints_rejected(rejected_constraints)
		#MRM: Access via Index redundant
		#if self.gui_refs[0].get_type_gui() == "reject": 
			#self.gui_refs[0].show_gui(current_action)
		#else:
		_get_gui_ref_by_name("reject_GUI").show_gui(current_action)
	else:
		_get_gui_ref_by_name(current_action.get_type_gui()).show_gui(current_action)


func _get_gui_ref_by_name(p_name : String) -> EMC_GUI:
	for ref: EMC_ActionGUI in self.gui_refs:
		if ref.get_type_gui() == p_name:
			return ref
	return null


func _on_action_executed(action : EMC_Action):
	
	match get_current_day_period():
		EMC_DayPeriod.MORNING:
			self.current_day_cycle = EMC_DayCycle.new()
			self.current_day_cycle.morning_action = action
		EMC_DayPeriod.NOON:
			self.current_day_cycle.noon_action = action
		EMC_DayPeriod.EVENING:
			self.current_day_cycle.evening_action = action
			self.history.append(self.current_day_cycle)
			_seodGUI.open(self.current_day_cycle)
			if _avatar_ref.get_hunger_status() <= 0 || _avatar_ref.get_thirst_status() <= 0 || _avatar_ref.get_health_status() <= 0 :
				avatar_life_status = false
			if get_current_day() >= self.max_day - 1 || !avatar_life_status:
				_egGUI.open(self.history, avatar_life_status)
			return
		#MRM: Defensive Programmierung: Ein "_" Fall sollte immer implementiert sein und Fehler werfen.
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()
	
func _check_pu_counter() -> void:
	_pu_GUI_counter -= 1
	if _pu_GUI_counter == 0:
		var _action := create_new_pop_up_action()
		_puGUI.open(_action, _avatar_ref)
		_pu_GUI_counter = _rng.randi_range(LOWER_RANGE,UPPER_RANGE)
	
func _on_seod_closed() -> void:
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()
	
func create_new_pop_up_action() -> EMC_PopUpAction:
	match get_current_day_period():
		EMC_DayPeriod.MORNING:
			var _counter_morning : int = _rng.randi_range(1, 2)
			match _counter_morning:
				1: return EMC_PopUpAction.new(1001, "PopUp_1", { }, "", "PopUp 1 happening")
				2: return EMC_PopUpAction.new(1002, "PopUp_2", { }, "", "PopUp 2 happening")
		EMC_DayPeriod.NOON:
			var _counter_noon : int = _rng.randi_range(1, 2)
			match _counter_noon:
				1: return EMC_PopUpAction.new(1001, "PopUp_1", { }, "", "PopUp 1 happening")
				2: return EMC_PopUpAction.new(1002, "PopUp_2", { }, "", "PopUp 2 happening")
		EMC_DayPeriod.EVENING: 
			var _counter_evening : int = _rng.randi_range(1, 2)
			match _counter_evening:
				1: return EMC_PopUpAction.new(1001, "PopUp_1", { }, "", "PopUp 1 happening")
				2: return EMC_PopUpAction.new(1002, "PopUp_2", { }, "", "PopUp 2 happening")
		_: 
			push_error("Unerwarteter Fehler PopUpAction")
	return null


func get_current_day_cycle() -> EMC_DayCycle:
	return current_day_cycle #MRM: could be changed later to: self.history[get_current_day()]


func get_current_day_period() -> EMC_DayPeriod:
	return self._period_cnt % 3 as EMC_DayPeriod


func get_current_day() -> int:
	return floor(self._period_cnt / 3.0)


func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag " + str(get_current_day() + 1)
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()

######################################## CONSTRAINT METHODS ########################################
func constraint_cooking() -> bool:
	print("Constraint Cooking was checked!")
	#TODO
	return false

########################################## CHANGE METHODS ##########################################
# "Changes" needed? See comment in Action.gd
func test_change() -> void:
	print("A change occurred!")

