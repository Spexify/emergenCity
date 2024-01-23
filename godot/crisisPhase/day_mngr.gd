extends Control

class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

signal period_ended

## Enum describing the periods of a Day.
enum EMC_DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

const NO_REJECTION: String = ""

var history : Array[EMC_DayCycle]
#MRM: Technically redundant: current_day_cycle = history[get_current_day()], if array initialized accordingly:
var current_day_cycle : EMC_DayCycle 

var _period_cnt : EMC_DayPeriod = EMC_DayPeriod.MORNING
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

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

# hyperparameters for random pop-up- and optional events respectively
var _puGUI_probability_countdown : int
const PU_LOWER_BOUND : int = 999 #MRM hab ich erhöht, weil sie manchmal nerven x)
const PU_UPPER_BOUND : int = 999 #MRM hab ich erhöht, weil sie manchmal nerven x)

var _opGUI_probability_countdown : int
const OP_LOWER_BOUND : int = 2
const OP_UPPER_BOUND : int = 4 

var _inventory : EMC_Inventory


func _create_action(p_action_ID: int) -> EMC_Action:
	var result: EMC_Action
	match p_action_ID:
		0: push_error("Action ID 0 sollte nicht erstellt werden!") #(unused) 
		1: push_error("Diese ID ist ausschließlich für das Triggern der CITY Map reserviert!")
		3: result = EMC_Action.new(p_action_ID, "Rest", { }, 
								 { }, "RestGUI", 
								 "Hat sich ausgeruht.", 10)
		4: result = EMC_Action.new(p_action_ID, "Cooking", {}, 
								 { }, "CookingGUI", 
								 "Hat gekocht.", 30)
		5: result = EMC_Action.new(p_action_ID, "Wasser aus Regentonne schöpfen", {"constraint_rainwater_barrel" : 0},
								{ }, "RainwaterBarrelGUI",
								"Hat Wasser aus der Regentonne geschöpft.",0)
		6: result = EMC_Action.new(p_action_ID, "Pop Up Event", { }, { }, "PopUpGUI", 
								 "Pop Up Aktion ausgeführt.", 0)
		7: result = EMC_Action.new(p_action_ID, "Filter Water", {"constraint_filter_water" : 0}, { }, "FilterWaterGUI", 
								 "Wasser ist gefiltert.", 0)
								
		#Stage Change Actions
		2000: result = EMC_StageChangeAction.new(p_action_ID, "nachhause", { }, 
								 "Nach Hause gekehrt.", 40, EMC_StageMngr.STAGENAME_HOME, Vector2i(450, 500))
		2001: result = EMC_StageChangeAction.new(p_action_ID, "zum Marktplatz", { "constraint_not_evening" : 0 }, 
								 "Hat Marktplatz besucht.", 0, EMC_StageMngr.STAGENAME_MARKET, Vector2i(250, 1000)) 
		_: push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
	result.executed.connect(_on_action_executed)
	return result


func setup(avatar_ref : EMC_Avatar,
overworld_states_mngr_ref : EMC_OverworldStatesMngr,
gui_refs : Array[EMC_ActionGUI],
p_tooltip_GUI : EMC_TooltipGUI,
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI, 
puGUI : EMC_PopUpGUI,
_p_inventory: EMC_Inventory,
max_day : int = 3) -> void:
	_avatar_ref = avatar_ref
	_overworld_states_mngr_ref = overworld_states_mngr_ref
	self.max_day = max_day
	self.gui_refs = gui_refs
	_tooltip_GUI = p_tooltip_GUI
	_seodGUI = seodGUI
	_egGUI = egGUI
	_inventory = _p_inventory
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
		var reject_reason: String = Callable(self, constraint_key).call()
		if reject_reason != NO_REJECTION:
			reject_reasons = reject_reasons + reject_reason + " "
	
	if reject_reasons == NO_REJECTION:
		var gui_name := current_action.get_type_gui()
		_get_gui_ref_by_name(gui_name).show_gui(current_action)
	else:
		_tooltip_GUI.open(reject_reasons)


func _get_gui_ref_by_name(p_name : String) -> EMC_GUI:
	for ref: EMC_ActionGUI in self.gui_refs:
		if ref.name == p_name:
			return ref
	return null


func _on_action_executed(action : EMC_Action) -> void:
	match get_current_day_period():
		EMC_DayPeriod.MORNING:
			if _avatar_life_status:
				self.current_day_cycle = EMC_DayCycle.new()
				self.current_day_cycle.morning_action = action
		EMC_DayPeriod.NOON:
			self.current_day_cycle.noon_action = action
		EMC_DayPeriod.EVENING:
			self.current_day_cycle.evening_action = action
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
		#MRM: Defensive Programmierung: Ein "_" Fall sollte immer implementiert sein und Fehler werfen.
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()
	_check_op_counter()
	period_ended.emit()


func _on_seod_closed_game_end() -> void:
	_egGUI.open(self.history, _avatar_life_status)

func _on_seod_closed() -> void:
	self._period_cnt += 1
	_update_HUD()
	_update_vitals()
	_check_pu_counter()
	_check_op_counter()

func get_current_day_cycle() -> EMC_DayCycle:
	return current_day_cycle #MRM: could be changed later to: self.history[get_current_day()]

func get_current_day_period() -> EMC_DayPeriod:
	return self._period_cnt % 3 as EMC_DayPeriod

func get_current_day() -> int:
	return floor(self._period_cnt / 3.0)

func _update_vitals() -> void:
	_avatar_ref.sub_nutrition(1) 
	_avatar_ref.sub_hydration(1)
	_avatar_ref.sub_health(1)

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
	
################################### Pop Up Events ##################################################
	
func _check_pu_counter() -> void:
	_puGUI_probability_countdown -= 1
	if _puGUI_probability_countdown == 0:
		var _action := _create_new_pop_up_action()
		_puGUI.open(_action, _avatar_ref)
		_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)
	
## TODO: refactor range und actions content
func _create_new_pop_up_action() -> EMC_PopUpAction:
	var result: EMC_PopUpAction
	match get_current_day_period():
		EMC_DayPeriod.MORNING:
			var _counter_morning : int = _rng.randi_range(1, 2)
			match _counter_morning:
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", 0, "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", 0, "PopUp 2 happening")
				_: 
					push_error("Unerwarteter Fehler PopUpAction")
		EMC_DayPeriod.NOON:
			var _counter_noon : int = _rng.randi_range(1, 2)
			match _counter_noon:
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", 0, "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", 0, "PopUp 2 happening")
				_: 
					push_error("Unerwarteter Fehler PopUpAction")
		EMC_DayPeriod.EVENING: 
			var _counter_evening : int = _rng.randi_range(1, 2)
			match _counter_evening:
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", 0, "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", 0, "PopUp 2 happening")
				_: 
					push_error("Unerwarteter Fehler PopUpAction")
		_: 
			push_error("Unerwarteter Fehler PopUpAction")
	result.executed.connect(_on_action_executed)
	return result
	
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

######################################## CONSTRAINT METHODS ########################################
func constraint_cooking() -> String:
	#TODO: Electricity?
	##TODO: In the future: Else Gaskocher?
	return "Grund warum kochen nicht möglich ist."
	#else:
	return NO_REJECTION
	
func constraint_rainwater_barrel() -> String:
	if _overworld_states_mngr_ref.get_furniture_state(_overworld_states_mngr_ref.Furniture.RAINWATER_BARREL) == 0:
		return "Die Regentonne ist leer"
	else:
		return NO_REJECTION

func constraint_filter_water() -> String:
	if !_inventory.has_item(2):
		return "Kein dreckiges Wasser ist zum Filtern verfügbar.]"
	if !_inventory.has_item(13):
		return "Keine Chlortabletten sind zum Filtern verfügbar.]"
	else:
		return NO_REJECTION

func constraint_not_morning() -> String:
	if get_current_day_period() == EMC_DayPeriod.MORNING:
		return "Man kann diese Aktion nicht morgens ausführen!"
	else:
		return NO_REJECTION


func constraint_not_noon() -> String:
	if get_current_day_period() == EMC_DayPeriod.NOON:
		return "Man kann diese Aktion nicht mittag ausführen!"
	else:
		return NO_REJECTION
		

func constraint_not_evening() -> String:
	if get_current_day_period() == EMC_DayPeriod.EVENING:
		return "Man kann diese Aktion nicht abends ausführen!"
	else:
		return NO_REJECTION


########################################## CHANGE METHODS ##########################################
# "Changes" needed? See comment in Action.gd
func test_change() -> void:
	print("A change occurred!")

