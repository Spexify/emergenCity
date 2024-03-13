extends Control
class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].


## Enum describing the periods of a Day.
enum DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

var _history : Array[EMC_DayCycle]
#MRM: Technically redundant: _current_day_cycle = history[get_current_day()], if array initialized accordingly:
var _current_day_cycle : EMC_DayCycle 
var _period_cnt : int = 0 #Keeps track of the current period (counted/summed up over all days)

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

#References to other scenes:
var _gui_refs : Array[EMC_ActionGUI]
var _tooltip_GUI : EMC_TooltipGUI
var _confirmation_GUI: EMC_ConfirmationGUI
var _seodGUI : EMC_SummaryEndOfDayGUI
var _egGUI : EMC_EndGameGUI
var _puGUI : EMC_PopUpGUI
var _avatar : EMC_Avatar
var _stage_mngr : EMC_StageMngr
var _crisis_mngr : EMC_CrisisMngr
var _inventory : EMC_Inventory
var _action_constraints: EMC_ActionConstraints
var _action_consequences: EMC_ActionConsequences
var _opt_event_mngr: EMC_OptionalEventMngr
var _pu_event_mngr: EMC_PopupEventMngr
var _day_period_transition: EMC_DayPeriodTransition

########################################## PUBLIC METHODS ##########################################
func setup(p_avatar : EMC_Avatar, p_stage_mngr : EMC_StageMngr,
p_crisis_mngr : EMC_CrisisMngr,
p_gui_refs : Array[EMC_ActionGUI],
p_tooltip_GUI : EMC_TooltipGUI,
p_confirmation_GUI: EMC_ConfirmationGUI,
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI,
p_inventory: EMC_Inventory,
p_lower_gui_node : Node,
p_opt_event_mngr: EMC_OptionalEventMngr,
p_pu_event_mngr: EMC_PopupEventMngr,
p_day_period_transition: EMC_DayPeriodTransition) -> void:
	_avatar = p_avatar
	_stage_mngr = p_stage_mngr
	_crisis_mngr = p_crisis_mngr
	_gui_refs = p_gui_refs
	_confirmation_GUI = p_confirmation_GUI
	_tooltip_GUI = p_tooltip_GUI
	_seodGUI = seodGUI
	_egGUI = egGUI
	_inventory = p_inventory
	_action_constraints = EMC_ActionConstraints.new(self, _inventory, _stage_mngr)
	_action_consequences = EMC_ActionConsequences.new(_avatar, p_inventory, _stage_mngr, \
		p_lower_gui_node, self, p_tooltip_GUI, p_opt_event_mngr, p_crisis_mngr)
	_opt_event_mngr = p_opt_event_mngr
	_pu_event_mngr = p_pu_event_mngr
	_day_period_transition = p_day_period_transition
	
	_rng.randomize()
	_update_HUD()


## MRM TODO: This function should be renamed, as it is used for other interactions as well!
func on_interacted_with_furniture(p_action_ID : int) -> void:
	#MRM: Duplicate of Objects cumbersome, and using the references of the array directly would
	#lead to errors. That's why I changed it, so it just creates a new instance each time:
	var current_action : EMC_Action = _create_action(p_action_ID)
	
	if current_action == null:
		return
	
	var reject_reasons: String
	for constraint_key: String in current_action.get_constraints_prior().keys():
		var param: Variant = current_action.get_constraints_prior()[constraint_key]
		var reject_reason: String = Callable(_action_constraints, constraint_key).call(param)
		if reject_reason != EMC_ActionConstraints.NO_REJECTION:
			reject_reasons = reject_reasons + reject_reason + " "
	
	if reject_reasons == EMC_ActionConstraints.NO_REJECTION:
		var gui_name := current_action.get_type_gui()
		if gui_name == "ConfirmationGUI":
			if await _confirmation_GUI.confirm(current_action.get_prompt()):
				_execute_consequences(current_action)
		else:
			_get_gui_ref_by_name(gui_name).show_gui(current_action)
	else:
		_tooltip_GUI.open(reject_reasons)


func get__current_day_cycle() -> EMC_DayCycle:
	return _history[get_current_day()]


func get_current_day_period() -> DayPeriod:
	return self._period_cnt % DayPeriod.size() as DayPeriod


func get_current_day() -> int:
	#+1 because: Day 1 = period 0, 1, 2, Day 2 = period 3, 4, 5, ....
	return floor(self._period_cnt / float(3.0)) + 1


func get_action_constraints() -> EMC_ActionConstraints:
	return _action_constraints


func get_action_consequences() -> EMC_ActionConsequences:
	return _action_consequences


########################################## PRIVATE METHODS #########################################
func _get_gui_ref_by_name(p_name : String) -> EMC_GUI:
	for ref: EMC_ActionGUI in _gui_refs:
		if ref.name == p_name:
			return ref
	return null


func _on_action_silent_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)


func _on_action_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)
	_advance_day_period(p_action)


## !!! Important function !!!
func _advance_day_period(p_action : EMC_Action) -> void:
	if !p_action.progresses_day_period(): return
	
	match get_current_day_period():
		DayPeriod.MORNING:
			_current_day_cycle = EMC_DayCycle.new()
			_current_day_cycle.morning_action = p_action
		DayPeriod.NOON:
			_current_day_cycle.noon_action = p_action
		DayPeriod.EVENING:
			_current_day_cycle.evening_action = p_action
			_history.append(_current_day_cycle)
			_seodGUI.open(_current_day_cycle)
			await _seodGUI.closed
			_avatar.update_vitals()
		_: push_error("Current day period unassigned!")
	
	#Actually advance the time
	self._period_cnt += 1
	
	#Game over?
	if _check_and_display_game_over(): return
	
	#play animation, do stuff and wait for it to finish
	_day_period_transition.start(get_current_day(), get_current_day_period())
	_update_HUD()
	if get_current_day_period() == DayPeriod.MORNING:
		_stage_mngr.change_stage(EMC_StageMngr.STAGENAME_HOME)
		_stage_mngr.deactivate_NPCs()
		_avatar.set_global_position(Vector2i(250, 650))
		_inventory._on_day_mngr_day_ended(get_current_day())
	await _day_period_transition.finished
	
	#Events & Crises stuff
	await _opt_event_mngr.check_for_new_event(get_current_day_period())
	
	if get_current_day_period() == DayPeriod.MORNING:
		await _crisis_mngr.check_crisis_status()
	
	# Popup last, because it can lead to another _advance_day_period() call!!!
	_pu_event_mngr.check_for_new_event()


## Execute the consequences of an action
## Doesn't have to move the time forward
func _execute_consequences(p_action: EMC_Action) -> void:
	for key : String in p_action.get_consequences().keys():
		var params : Variant = p_action.get_consequences()[key]
		Callable(_action_consequences, key).call(params)


## Checks for game over conditions and displays the endscreen GUI if needed
func _check_and_display_game_over() -> bool:
	var avatar_life_status : bool = true
	if _avatar.get_nutrition_status() <= 0 || _avatar.get_hydration_status() <= 0 || \
	_avatar.get_health_status() <= 0 :
		avatar_life_status = false
	
	if get_current_day() >= _crisis_mngr.get_max_day() || !avatar_life_status:
		_egGUI.open(_history, avatar_life_status, _avatar)
		return true
	return false


## Update the visual representation of the current daytime
func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag " + str(get_current_day())
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()


func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"period_cnt": _period_cnt,
		"_current_day_cycle": _current_day_cycle.save() if _current_day_cycle != null else EMC_DayCycle.new().save(),
		"history" : _history.map(func(cycle : EMC_DayCycle) -> Dictionary: return cycle.save()),
	}
	return data


func load_state(data : Dictionary) -> void:
	_period_cnt = data.get("period_cnt", 0)
	_current_day_cycle = EMC_DayCycle.new()
	_current_day_cycle.load_state(data.get("_current_day_cycle"))
	_history.assign(data.get("history").map(
		func(data : Dictionary) -> EMC_DayCycle: 
			var cycle : EMC_DayCycle = EMC_DayCycle.new()
			cycle.load_state(data)
			return cycle) as Array[EMC_DayCycle])
	_update_HUD()
	if _current_day_cycle.evening_action.get_ACTION_NAME() != "":
		print("Ha du versuchst zu cheaten")


func _create_action(p_action_ID: int) -> EMC_Action:
	var result: EMC_Action
	match p_action_ID:
		EMC_Action.IDs.NO_ACTION:
			push_error("Action ID 0 sollte nicht erstellt werden!") #(unused)
		
		#FYI: Stage Change actions and others are imported via JSON
		var id: 
			if 1 <= id and id < 2000:
				result = JsonMngr.id_to_action(id) as EMC_Action
			if 2000 <= id and id < 3000:
				result = JsonMngr.id_to_action(id) as EMC_StageChangeAction
			else:
				push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
	
	result.executed.connect(_on_action_executed)
	result.silent_executed.connect(_on_action_silent_executed)
	return result
