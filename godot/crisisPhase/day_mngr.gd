extends Control

class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

signal period_ended(p_new_period: DayPeriod)
signal day_ended(p_curr_day: int)

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
var _period_cnt : int = 0

var gui_refs : Array[EMC_ActionGUI]
var _tooltip_GUI : EMC_TooltipGUI
var _confirmation_GUI: EMC_ConfirmationGUI
var _seodGUI : EMC_SummaryEndOfDayGUI
var _egGUI : EMC_EndGameGUI
var _puGUI : EMC_PopUpGUI
var _avatar : EMC_Avatar
var _stage_mngr : EMC_StageMngr
var _crisis_mngr : EMC_CrisisMngr

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

# hyperparameters for random pop-up- and optional events respectively
var _puGUI_probability_countdown : int
const PU_LOWER_BOUND : int = 3
const PU_UPPER_BOUND : int = 6

var _inventory : EMC_Inventory
var _action_constraints: EMC_ActionConstraints
var _action_consequences: EMC_ActionConsequences


########################################## PUBLIC METHODS ##########################################
func setup(avatar_ref : EMC_Avatar, stage_mngr : EMC_StageMngr,
p_crisis_mngr : EMC_CrisisMngr,
gui_refs : Array[EMC_ActionGUI],
p_tooltip_GUI : EMC_TooltipGUI,
p_confirmation_GUI: EMC_ConfirmationGUI,
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI, 
puGUI : EMC_PopUpGUI,
p_inventory: EMC_Inventory,
p_lower_gui_node : Node,
p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_avatar = avatar_ref
	_stage_mngr = stage_mngr
	_crisis_mngr = p_crisis_mngr
	_confirmation_GUI = p_confirmation_GUI
	_tooltip_GUI = p_tooltip_GUI
	_seodGUI = seodGUI
	_egGUI = egGUI
	_inventory = p_inventory
	_puGUI = puGUI
	_action_constraints = EMC_ActionConstraints.new(self, _inventory, _stage_mngr)
	_action_consequences = EMC_ActionConsequences.new(_avatar, p_inventory, _stage_mngr, \
		p_lower_gui_node, self, p_tooltip_GUI, p_opt_event_mngr, p_crisis_mngr)
	self.gui_refs = gui_refs
	_rng.randomize()
	_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)
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
	for ref: EMC_ActionGUI in self.gui_refs:
		if ref.name == p_name:
			return ref
	return null


func _on_action_silent_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)


func _on_action_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)
	_advance_day_time(p_action)


func _advance_day_time(p_action : EMC_Action) -> void:
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
			_seodGUI.closed.connect(_on_seod_closed)
			return
		_: push_error("Current day period unassigned!")
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()
	period_ended.emit(get_current_day_period())


## Execute the consequences of an action
## Doesn't have to move the time forward
func _execute_consequences(p_action: EMC_Action) -> void:
	for key : String in p_action.get_consequences().keys():
		var params : Variant = p_action.get_consequences()[key]
		Callable(_action_consequences, key).call(params)


## Defines what happens after the "summery and of day" GUI is closed
func _on_seod_closed() -> void:
	self._period_cnt += 1
	#Send avatar back home on a new day
	_stage_mngr.change_stage(EMC_StageMngr.STAGENAME_HOME)
	_stage_mngr.deactivate_NPCs()
	_avatar.set_global_position(Vector2i(250, 650))
	
	_update_HUD()
	_check_pu_counter()
	#Order has to be this way, because the transition animation needs to update
	#its day first:
	day_ended.emit(get_current_day())
	period_ended.emit(get_current_day_period())
	_check_game_over()


func _check_game_over() -> bool:
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
		EMC_Action.IDs.CITY_MAP:
			result = EMC_Action.new(p_action_ID, "-",
				{ "constraint_no_isolation" : "Die City Map ist aufgrund einer Isolationsverordnung nicht betretbar!" }, 
				{ }, "CityMap", 
				"-", "", 0, false)
		EMC_Action.IDs.COOKING:
			result = EMC_Action.new(p_action_ID, "Kochen", {}, 
				{ }, "CookingGUI", 
				"Hat gekocht.", "", 30)
		EMC_Action.IDs.TAP_WATER:
			result = EMC_Action.new(p_action_ID, "(Wasserzapfen)",
				{ "constraint_some_water_available" : ""},
				{ "add_tap_water" : EMC_ActionConsequences.NO_PARAM}, "DefaultActionGUI",
				"-", "Willst du Wasser aus dem Hahn zapfen?", 0, false)
		EMC_Action.IDs.REST:
			result = EMC_Action.new(p_action_ID, "Ausruhen", { }, 
				{}, "DefaultActionGUI",
				"Hat sich ausgeruht.", "Willst du dich ausruhen?", 10, true) 
		EMC_Action.IDs.RAINWATER_BARREL:
			result = EMC_Action.new(p_action_ID, "Wasser aus Regentonne schöpfen",
				{"constraint_rainwater_barrel" : 0},
				{ }, "RainwaterBarrelGUI",
				"Hat Wasser aus der Regentonne geschöpft.", "", 0)
		EMC_Action.IDs.SHOWER:
			result = EMC_Action.new(p_action_ID, "Duschen", { },
				{ }, "ShowerGUI", #the consequences are added later in the GUI as they are variable
				"Hat geduscht.", "", 10)
		EMC_Action.IDs.BBK_LINK:
			result = EMC_Action.new(p_action_ID, "(BBK-Broschürenlink)", { },
				{ "open_bbk_brochure" : EMC_ActionConsequences.NO_PARAM }, "ConfirmationGUI",
				"-", "Willst du die Bevölkerungsschutz und Katastrophenhilfe Broschüre im Browser öffnen?", 0)
		EMC_Action.IDs.ELECTRIC_RADIO:
			result = EMC_Action.new(p_action_ID, "(Radio)", { "constraint_has_item" : JsonMngr.item_name_to_id("BATTERIES") },
				{ "use_item" : JsonMngr.item_name_to_id("BATTERIES"), "use_radio" : EMC_ActionConsequences.NO_PARAM },
				"ConfirmationGUI", "-", "Willst du das Radio benutzen? Dies verbraucht eine Batterie-Ladung!", 0)
		EMC_Action.IDs.CRANK_RADIO:
			result = EMC_Action.new(p_action_ID, "(Radio)", { },
				{ "use_radio" : EMC_ActionConsequences.NO_PARAM },
				"ConfirmationGUI", "-", "Willst du das Kurbelradio benutzen?", 0)
		
		#FYI: Stage Change actions and others are imported via JSON
		
		var id: 
			if 2000 <= id and id < 3000:
				result = JsonMngr.id_to_action(id) as EMC_StageChangeAction
			else:
				push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
				
	result.executed.connect(_on_action_executed)
	result.silent_executed.connect(_on_action_silent_executed)
	return result


################################### Pop Up Events ##################################################
func _check_pu_counter() -> void:
	_puGUI_probability_countdown -= 1
	if _puGUI_probability_countdown == 0:
		var _action : EMC_PopUpAction = JsonMngr.get_pop_up_action(_action_constraints)
		if _action != null:
			_action.executed.connect(_on_action_executed)
			_action.silent_executed.connect(_on_action_silent_executed)
			_puGUI.open(_action)
		_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)
