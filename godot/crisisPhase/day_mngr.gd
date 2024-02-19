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


var history : Array[EMC_DayCycle]
#MRM: Technically redundant: current_day_cycle = history[get_current_day()], if array initialized accordingly:
var current_day_cycle : EMC_DayCycle 

var _period_cnt : DayPeriod = DayPeriod.MORNING
#var current_day : int = 0 #MRM: Redundant: Can be deduced through period_cnt (use getters)
var max_day : int

#var _actionArr : Array[EMC_Action] #MRM: Curr not used anymore
var gui_refs : Array[EMC_ActionGUI]
var _tooltip_GUI : EMC_TooltipGUI
var _seodGUI : EMC_SummaryEndOfDayGUI
var _egGUI : EMC_EndGameGUI
var _puGUI : EMC_PopUpGUI

var _avatar_ref : EMC_Avatar
var _avatar_life_status : bool = true

var _overworld_states_mngr_ref : EMC_OverworldStatesMngr
var _crisis_mngr : EMC_CrisisMngr

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

# hyperparameters for random pop-up- and optional events respectively
var _puGUI_probability_countdown : int
const PU_LOWER_BOUND : int = 6
const PU_UPPER_BOUND : int = 10

var _opGUI_probability_countdown : int
const OP_LOWER_BOUND : int = 2
const OP_UPPER_BOUND : int = 4 

var _inventory : EMC_Inventory
var _action_constraints: EMC_ActionConstraints
var _action_consequences: EMC_ActionConsequences


########################################## PUBLIC METHODS ##########################################
func setup(avatar_ref : EMC_Avatar,
overworld_states_mngr_ref : EMC_OverworldStatesMngr,
p_crisis_mngr : EMC_CrisisMngr,
gui_refs : Array[EMC_ActionGUI],
p_tooltip_GUI : EMC_TooltipGUI,
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI, 
puGUI : EMC_PopUpGUI,
p_inventory: EMC_Inventory) -> void:
	_avatar_ref = avatar_ref
	_overworld_states_mngr_ref = overworld_states_mngr_ref
	_crisis_mngr = p_crisis_mngr
	_action_constraints = EMC_ActionConstraints.new(self, _overworld_states_mngr_ref)
	_action_consequences = EMC_ActionConsequences.new(_avatar_ref, p_inventory)
	
	self.max_day = p_crisis_mngr.get_max_day()
	self.gui_refs = gui_refs
	_tooltip_GUI = p_tooltip_GUI
	_seodGUI = seodGUI
	_egGUI = egGUI
	_inventory = p_inventory
	_puGUI = puGUI
	_rng.randomize()
	_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)
	_opGUI_probability_countdown = _rng.randi_range(OP_LOWER_BOUND, OP_UPPER_BOUND)
	_update_HUD()


## MRM TODO: This function should be renamed, as it is used for other interactions as well!
func on_interacted_with_furniture(action_id : int) -> void:
	#MRM: Duplicate of Objects cumbersome, and using the references of the array directly would
	#lead to errors. That's why I changed it, so it just creates a new instance each time:
	var current_action : EMC_Action = _create_action(action_id)
	
	var reject_reasons: String
	for constraint_key: String in current_action.get_constraints_prior().keys():
		var param: Variant = current_action.get_constraints_prior()[constraint_key]
		var reject_reason: String = Callable(_action_constraints, constraint_key).call(param)
		if reject_reason != EMC_ActionConstraints.NO_REJECTION:
			reject_reasons = reject_reasons + reject_reason + " "
	
	if reject_reasons == EMC_ActionConstraints.NO_REJECTION:
		var gui_name := current_action.get_type_gui()
		_get_gui_ref_by_name(gui_name).show_gui(current_action)
	else:
		_tooltip_GUI.open(reject_reasons)


func get_current_day_cycle() -> EMC_DayCycle:
	return current_day_cycle #MRM: could be changed later to: self.history[get_current_day()]


func get_current_day_period() -> DayPeriod:
	return self._period_cnt % 3 as DayPeriod


func get_current_day() -> int:
	return floor(self._period_cnt / float(3.0))


########################################## PRIVATE METHODS #########################################
func _get_gui_ref_by_name(p_name : String) -> EMC_GUI:
	for ref: EMC_ActionGUI in self.gui_refs:
		if ref.name == p_name:
			return ref
	return null


func _on_action_executed(p_action : EMC_Action) -> void:
	_execute_consequences(p_action)
	if !p_action.progresses_day_period(): return
	
	match get_current_day_period():
		DayPeriod.MORNING:
			if _avatar_life_status:
				self.current_day_cycle = EMC_DayCycle.new()
				self.current_day_cycle.morning_action = p_action
				_crisis_mngr.check_crisis_status()
		DayPeriod.NOON:
			self.current_day_cycle.noon_action = p_action
		DayPeriod.EVENING:
			self.current_day_cycle.evening_action = p_action
			self.history.append(self.current_day_cycle)
			_seodGUI.open(self.current_day_cycle)
			_seodGUI.closed.connect(_on_seod_closed)
			if _avatar_ref.get_nutrition_status() <= 0 || _avatar_ref.get_hydration_status() <= 0 || _avatar_ref.get_health_status() <= 0 :
				_avatar_life_status = false
			if get_current_day() >= self.max_day - 1 || !_avatar_life_status:
				_seodGUI.open(self.current_day_cycle)
				_seodGUI.closed.connect(_on_seod_closed_game_end)
			return
		_: push_error("Current day period unassigned!")
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()
	_check_op_counter()
	period_ended.emit(get_current_day_period())


func _execute_consequences(p_action: EMC_Action) -> void:
	for key : String in p_action.get_consequences().keys():
		var params : Variant = p_action.get_consequences()[key]
		Callable(_action_consequences, key).call(params)


func _on_seod_closed_game_end() -> void:
	_egGUI.open(self.history, _avatar_life_status, _avatar_ref)


func _on_seod_closed() -> void:
	self._period_cnt += 1
	_update_HUD()
	_update_vitals()
	_check_pu_counter()
	_check_op_counter()
	_update_shelflives()
	day_ended.emit(get_current_day())
	period_ended.emit(get_current_day_period())


func _update_vitals() -> void:
	_avatar_ref.sub_nutrition() 
	_avatar_ref.sub_hydration()
	_avatar_ref.add_health()


func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag " + str(get_current_day() + 1)
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()


func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"period_cnt": _period_cnt,
		"current_day_cycle": current_day_cycle.save() if current_day_cycle != null else EMC_DayCycle.new().save(),
		"history" : history.map(func(cycle : EMC_DayCycle) -> Dictionary: return cycle.save()),
	}
	return data


func load_state(data : Dictionary) -> void:
	_period_cnt = data.get("period_cnt", 0)
	current_day_cycle = EMC_DayCycle.new()
	current_day_cycle.load_state(data.get("current_day_cycle"))
	history.assign(data.get("history").map(
		func(data : Dictionary) -> EMC_DayCycle: 
			var cycle : EMC_DayCycle = EMC_DayCycle.new()
			cycle.load_state(data)
			return cycle) as Array[EMC_DayCycle])
	_update_HUD()


func _update_shelflives() -> void:
	for item: EMC_Item in _inventory.get_all_items():
		var IC_shelflife : EMC_IC_Shelflife = item.get_comp(EMC_IC_Shelflife)
		if (IC_shelflife != null):
			IC_shelflife.reduce_shelflife()
			# When an items spoils, replace the shelflive component with an unpalatable component
			if IC_shelflife.is_spoiled():
				item.remove_comp(EMC_IC_Shelflife)
				item.add_comp(EMC_IC_Unpalatable.new(1))


func _create_action(p_action_ID: int) -> EMC_Action:
	var result: EMC_Action
	match p_action_ID:
		EMC_Action.IDs.NO_ACTION: push_error("Action ID 0 sollte nicht erstellt werden!") #(unused)
		EMC_Action.IDs.CITY_MAP: result = EMC_Action.new(p_action_ID, "-",
								{ "constraint_no_isolation" : "Die City Map ist aufgrund einer Isolationsverordnung nicht betretbar!" }, 
								 { }, "CityMap", 
								 "-", 0, false)
		EMC_Action.IDs.COOKING: result = EMC_Action.new(p_action_ID, "Kochen", {}, 
								 { }, "CookingGUI", 
								 "Hat gekocht.", 30)
		EMC_Action.IDs.TAP_WATER: result = EMC_Action.new(p_action_ID, "Willst du Wasser aus dem Hahn zapfen?",
								{ "constraint_some_water_available" : ""},
								{ "add_tap_water" : 0}, "DefaultActionGUI",
								"-", 0, false)
		EMC_Action.IDs.REST: result = EMC_Action.new(p_action_ID, "Ausruhen", { }, 
								 {"add_health" : 1 }, "RestGUI", 
								 "Hat sich ausgeruht.", 10)
		EMC_Action.IDs.RAINWATER_BARREL: result = EMC_Action.new(p_action_ID, "Wasser aus Regentonne schöpfen",
								{"constraint_rainwater_barrel" : 0},
								{ }, "RainwaterBarrelGUI",
								"Hat Wasser aus der Regentonne geschöpft.",0)
		EMC_Action.IDs.SHOWER: result = EMC_Action.new(p_action_ID, "Duschen", { },
								{ }, "ShowerGUI", #the consequences are added later in the GUI
								"Hat geduscht.", 10)
		#Stage Change Actions
		EMC_Action.IDs.SC_HOME: result = EMC_StageChangeAction.new(p_action_ID, "nachhause", { }, 
								 "Nach Hause gekehrt.", 40, EMC_StageMngr.STAGENAME_HOME, Vector2i(250, 750),
								{ })
		EMC_Action.IDs.SC_MARKET: result = EMC_StageChangeAction.new(p_action_ID, "zum Marktplatz", { "constraint_not_evening" : "" }, 
								 "Hat Marktplatz besucht.", 0, EMC_StageMngr.STAGENAME_MARKET, Vector2i(250, 1000),
								{"Mert" : Vector2(470, 380)}) 
		EMC_Action.IDs.SC_TOWNHALL: result = EMC_StageChangeAction.new(p_action_ID, "zum Rathaus", \
								{ "constraint_not_evening" : "Das Rathaus ist Abends geschlossen." }, 
								 "Hat Rathaus besucht.", 0, EMC_StageMngr.STAGENAME_TOWNHALL, Vector2i(450, 480),
								{"TownhallWorker" : Vector2(430, 300)}) 
		EMC_Action.IDs.SC_PARK: result = EMC_StageChangeAction.new(p_action_ID, "zum Park", \
								{ "constraint_not_evening" : "Abends kann der Park gefährlich werden!" }, 
								 "Hat den Park besucht.", 0, EMC_StageMngr.STAGENAME_PARK, Vector2i(350, 700),
								{"Gerhard" : Vector2(160, 730), "Friedel" : Vector2(80, 730)}) 
		EMC_Action.IDs.SC_GARDENHOUSE: result = EMC_StageChangeAction.new(p_action_ID, "zu Gerhard", { }, 
								 "Hat Gerhard besucht.", 0, EMC_StageMngr.STAGENAME_GARDENHOUSE, Vector2i(150, 900),
								{"Gerhard" : Vector2(420, 380), "Friedel" : Vector2(80, 700)}) 
		EMC_Action.IDs.SC_ROWHOUSE: result = EMC_StageChangeAction.new(p_action_ID, "zu Julia", { }, 
								 "Hat Julia besucht.", 0, EMC_StageMngr.STAGENAME_ROWHOUSE, Vector2i(250, 400),
								{"Julia" : Vector2(450, 550)}) 
		EMC_Action.IDs.SC_MANSION: result = EMC_StageChangeAction.new(p_action_ID, "zu Petro & Irena", { }, 
								 "Hat Petro & Irena besucht.", 0, EMC_StageMngr.STAGENAME_MANSION, Vector2i(120, 900),
								{"Petro" : Vector2(370, 870), "Irena" : Vector2(460, 260)}) 
		EMC_Action.IDs.SC_PENTHOUSE: result = EMC_StageChangeAction.new(p_action_ID, "zu Elias", { }, 
								 "Hat Elias besucht.", 0, EMC_StageMngr.STAGENAME_PENTHOUSE, Vector2i(250, 1000),
								{"Elias" : Vector2(440, 800)}) 
		EMC_Action.IDs.SC_APARTMENT_MERT: result = EMC_StageChangeAction.new(p_action_ID, "zu Mert", \
								{ "constraint_not_noon" : "Mert ist Mittags nicht zuhause" }, 
								 "Hat Mert besucht.", 0, EMC_StageMngr.STAGENAME_APARTMENT_MERT, Vector2i(150, 400),
								{"Mert" : Vector2(400, 310), "Momo" : Vector2(480, 760)}) 
		EMC_Action.IDs.SC_APARTMENT_CAMPER: result = EMC_StageChangeAction.new(p_action_ID, "zu Kris & Veronika", { }, 
								 "Hat Kris & Veronika besucht.", 0, EMC_StageMngr.STAGENAME_APARTMENT_CAMPER, Vector2i(150, 400),
								{"Kris" : Vector2(460, 300), "Veronika" : Vector2(480, 780)}) 
		EMC_Action.IDs.SC_APARTMENT_AGATHE: result = EMC_StageChangeAction.new(p_action_ID, "zu Agathe", { }, 
								 "Hat Agathe besucht.", 0, EMC_StageMngr.STAGENAME_APARTMENT_DEFAULT, Vector2i(250, 900),
								{"Agathe" : Vector2(490, 400)}) 
		_: push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
	result.executed.connect(_on_action_executed)
	return result


################################### Pop Up Events ##################################################
func _check_pu_counter() -> void:
	_puGUI_probability_countdown -= 1
	if _puGUI_probability_countdown == 0:
		var _action : EMC_PopUpAction = JsonMngr.get_pop_up_action(_action_constraints)
		if _action != null:
			_action.executed.connect(_on_action_executed)
			_puGUI.open(_action)
		_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)


################################### Optional Events ################################################

func _check_op_counter() -> void:
	_opGUI_probability_countdown -= 1
	if _opGUI_probability_countdown == 0:
		_create_new_optional_event()
		_opGUI_probability_countdown = _rng.randi_range(OP_LOWER_BOUND, OP_UPPER_BOUND)


func _create_new_optional_event() -> void:
	# currently only one event, the RAINWATER_BARREL is implemented
	# With more content, this should be a match statement similar to create_pop_up_action
	var _added_water_quantity : int = _rng.randi_range(1, 6) # in units of 250ml
	_overworld_states_mngr_ref.set_furniture_state(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL, 
		min(_overworld_states_mngr_ref.get_furniture_state_maximum(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL), 
			(_overworld_states_mngr_ref.get_furniture_state(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL) + _added_water_quantity)))
	_tooltip_GUI.open("Es hat geregnet")

