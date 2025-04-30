extends Control
class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

signal period_increased(new_value : int)

## Enum describing the periods of a Day.
enum DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

#var _history : Array[EMC_DayCycle]
var _day_hist: Array[String]
var _history: Array
#MRM: Technically redundant: _current_day_cycle = history[get_current_day()], if array initialized accordingly:
var _period_cnt : int = 0 #Keeps track of the current period (counted/summed up over all days)

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

#References to other scenes:
@export var _gui_mngr : EMC_GUIMngr
@export var _avatar : EMC_Avatar
@export var _stage_mngr : EMC_StageMngr
var _crisis_mngr : EMC_CrisisMngr = EMC_CrisisMngr.new()
var _inventory : EMC_Inventory
@export var _action_constraints: EMC_ActionConstraints
@export var _action_consequences: EMC_ActionConsequences
var _opt_event_mngr: EMC_OptionalEventMngr

########################################## PUBLIC METHODS ##########################################
func setup(
p_inventory: EMC_Inventory,
p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_inventory = p_inventory

	_crisis_mngr.setup(_inventory, _gui_mngr)
	
	_opt_event_mngr = p_opt_event_mngr
	
	_opt_event_mngr.set_constraints(_action_constraints)
	_opt_event_mngr.set_consequences(_action_consequences)
	
	_rng.randomize()
	_update_HUD()
	
	# Called before once game starts
	_crisis_mngr.check_crisis_status(0)
	_stage_mngr.let_npcs_act()


## MRM TODO: This function should be renamed, as it is used for other interactions as well!
func on_interacted_with_furniture(p_action_ID : int) -> void:
	#MRM: Duplicate of Objects cumbersome, and using the references of the array directly would
	#lead to errors. That's why I changed it, so it just creates a new instance each time:
	#var current_action : EMC_Action = _create_action(p_action_ID)
	#
	#if current_action == null:
		#return
	#
	#var reject_reasons: String
	#for constraint_key: String in current_action.get_constraints_prior().keys():
		#var param: Variant = current_action.get_constraints_prior()[constraint_key]
		#var reject_reason: String = Callable(_action_constraints, constraint_key).call(param)
		#if reject_reason != EMC_ActionConstraints.NO_REJECTION:
			#reject_reasons = reject_reasons + reject_reason + " "
	#
	#if reject_reasons == EMC_ActionConstraints.NO_REJECTION:
		#var gui_name := current_action.get_type_gui()
		#if gui_name == "ConfirmationGUI":
			#if await _gui_mngr.request_gui("ConfirmationGUI", [current_action.get_prompt()]):
				#_execute_consequences(current_action)
		#else:
			#_gui_mngr.request_gui(gui_name, [current_action])
	#else:
		#_gui_mngr.request_gui("TooltipGUI", [reject_reasons])
		
	JsonMngr.get_action(str(p_action_ID)).execute()


func get__current_day_cycle() -> EMC_DayCycle:
	return _history[get_current_day()]


func get_current_day_period() -> DayPeriod:
	return self._period_cnt % DayPeriod.size() as DayPeriod


func get_current_day() -> int:
	#+1 because: Day 1 = period 0, 1, 2, Day 2 = period 3, 4, 5, ....
	return floor(self._period_cnt / float(3.0)) + 1

func get_period_count() -> int:
	return self._period_cnt

func get_action_constraints() -> EMC_ActionConstraints:
	return _action_constraints


func get_action_consequences() -> EMC_ActionConsequences:
	return _action_consequences


########################################## PRIVATE METHODS #########################################


func _on_action_silent_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)
	
	if !p_action.progresses_day_period():
		var closed : Signal = _gui_mngr.queue_gui("DayPeriodTransition", [get_current_day(), get_current_day_period(), true])
		
		_stage_mngr.let_npcs_act()
	
		await Global.get_tree().create_timer(0.3).timeout
		period_increased.emit(_period_cnt)
		
		#Events & Crises stuff
		_opt_event_mngr.check_for_new_event(get_current_day_period())

		#if get_current_day_period() == DayPeriod.MORNING:
		_crisis_mngr.check_crisis_status(get_period_count())

func _on_action_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)
	_advance_day_period(p_action._description)

func _callback() -> void:
	if get_current_day_period() == DayPeriod.MORNING:
		await _gui_mngr.request_gui("SummaryEndOfDayGUI", [_day_hist])
		await _gui_mngr.request_gui("BackpackGUI", [true])
		_avatar.update_vitals()
		_day_hist = []

## !!! Important function !!!
func _advance_day_period(description : String) -> void:
	#if !p_action.progresses_day_period(): return
	
	#match get_current_day_period():
		#DayPeriod.MORNING:
			#_current_day_cycle = EMC_DayCycle.new()
			#_current_day_cycle.morning_action = p_action
		#DayPeriod.NOON:
			#_current_day_cycle.noon_action = p_action
		#DayPeriod.EVENING:
			#_current_day_cycle.evening_action = p_action
			#_history.append(_current_day_cycle)
		#_: push_error("Current day period unassigned!")
	
	if get_current_day_period() == DayPeriod.EVENING:
		_day_hist.append(description)
		_history.append(_day_hist)
	else:
		_day_hist.append(description)
	
	if _gui_mngr.is_any_gui():
		await _gui_mngr.all_guis_closed
	
	#Actually advance the time
	self._period_cnt += 1
	
	var closed : Signal = _gui_mngr.queue_gui("DayPeriodTransition", [get_current_day(), get_current_day_period(), false, _callback])
	_update_HUD()
	
	
	await Global.get_tree().create_timer(0.3).timeout
	# let npcs act
	_stage_mngr.let_npcs_act()
	period_increased.emit(_period_cnt)
	
	if get_current_day_period() == DayPeriod.MORNING:
		if _stage_mngr.get_curr_stage_name() != EMC_StageMngr.STAGENAME_HOME:
			_stage_mngr.change_stage(EMC_StageMngr.STAGENAME_HOME, {}, false)
			#_stage_mngr.deactivate_NPCs()
			_avatar.set_global_position(Vector2i(250, 650))
			
		_inventory._on_day_mngr_day_ended(get_current_day())
	
	if not closed.is_null():
		await closed
	
	#Game over?
	if _check_and_display_game_over(): return
	
	#Events & Crises stuff
	_opt_event_mngr.check_for_new_event(get_current_day_period())
	
	if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED:
		_inventory.spoil_some_items()
	
	#if get_current_day_period() == DayPeriod.MORNING:
	_crisis_mngr.check_crisis_status(get_period_count())
	
	# Popup last, because it can lead to another _advance_day_period() call!!!
	#_pu_event_mngr.check_for_new_event()


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
		_gui_mngr.queue_gui("EndGameGUI", [_history, avatar_life_status, _avatar])
		return true
	return false


## Update the visual representation of the current daytime
func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag" + " " + str(get_current_day())
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()


func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"period_cnt": _period_cnt,
		"_current_day_cycle": _day_hist,
		"history" : _history.map(func(cycle : EMC_DayCycle) -> Dictionary: return cycle.save()),
	}
	return data


func load_state(data : Dictionary) -> void:
	_period_cnt = data.get("period_cnt", 0)
	_day_hist = data.get("_current_day_cycle")
	_history.assign(data.get("history").map(
		func(data : Dictionary) -> EMC_DayCycle: 
			var cycle : EMC_DayCycle = EMC_DayCycle.new()
			cycle.load_state(data)
			return cycle) as Array[EMC_DayCycle])
	_update_HUD()
	if _day_hist.size() < 3:
		print("Ha du versuchst zu cheaten")


#func _create_action(p_action_ID: int) -> EMC_Action:
	#var result: EMC_Action
	#match p_action_ID:
		#EMC_Action.IDs.NO_ACTION:
			#push_error("Action ID 0 sollte nicht erstellt werden!") #(unused)
		#
		##FYI: Stage Change actions and others are imported via JSON
		#var id: 
			#if 1 <= id and id < 2000:
				#result = JsonMngr.id_to_action(id) as EMC_Action
			#elif 2000 <= id and id < 3000:
				#result = JsonMngr.id_to_action(id) as EMC_StageChangeAction
			#else:
				#push_error("Action kann nicht zu einer unbekannten Action-ID(" + str(id) + ") instanziiert werden!")
	#
	#if not result.executed.is_connected(_on_action_executed):
		#result.executed.connect(_on_action_executed)
	#if not result.silent_executed.is_connected(_on_action_silent_executed):
		#result.silent_executed.connect(_on_action_silent_executed)
	#return result
