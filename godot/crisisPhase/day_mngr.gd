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
var _avatar_life_status : bool = true

var _overworld_states_mngr_ref : EMC_OverworldStatesMngr

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

# hyperparameters for random pop-up- and optional events respectively
var _puGUI_probability_countdown : int
const PU_LOWER_BOUND : int = 2 #MRM hab ich erhöht, weil sie manchmal nerven x)
const PU_UPPER_BOUND : int = 4 #MRM hab ich erhöht, weil sie manchmal nerven x)

var _opGUI_probability_countdown : int
const OP_LOWER_BOUND : int = 2
const OP_UPPER_BOUND : int = 4 


func _create_action(p_action_ID: int) -> EMC_Action:
	var result: EMC_Action
	match p_action_ID:
		0: push_error("Action ID 0 sollte nicht erstellt werden!") #(unused) 
		1: push_error("Diese ID ist ausschließlich für das Triggern der CITY Map reserviert!")
		3: result = EMC_Action.new(p_action_ID, "Rest", { }, 
								 { }, "RestGUI", 
								 "Hat sich ausgeruht.")
		4: result = EMC_Action.new(p_action_ID, "Cooking", { "constraint_cooking" : 0 }, 
								 { }, "cooking_GUI", 
								 "Hat gekocht.")
		5: result = EMC_Action.new(p_action_ID, "Pop Up Event", { }, { }, "PopUpGUI", 
								 "Pop Up Aktion ausgeführt.")
		#Stage Change Actions
		2000: result = EMC_StageChangeAction.new(p_action_ID, "nachhause", { }, 
								 "Nach Hause gekehrt.", EMC_StageMngr.STAGENAME_HOME, Vector2i(450, 500))
		2001: result = EMC_StageChangeAction.new(p_action_ID, "zum Marktplatz", { "constraint_not_evening" : 0 }, 
								 "Hat Marktplatz besucht.", EMC_StageMngr.STAGENAME_MARKET, Vector2i(250, 1000)) 
		_: push_error("Action kann nicht zu einer unbekannten Action-ID instanziiert werden!")
	result.executed.connect(_on_action_executed)
	return result


func setup(avatar_ref : EMC_Avatar,
overworld_states_mngr_ref : EMC_OverworldStatesMngr,
gui_refs : Array[EMC_ActionGUI],
seodGUI: EMC_SummaryEndOfDayGUI,
egGUI : EMC_EndGameGUI, 
puGUI : EMC_PopUpGUI, max_day : int = 3) -> void:
	_avatar_ref = avatar_ref
	_overworld_states_mngr_ref = overworld_states_mngr_ref
	self.max_day = max_day
	self.gui_refs = gui_refs
	_seodGUI = seodGUI
	_egGUI = egGUI
	_puGUI = puGUI
	_rng.randomize()
	_puGUI_probability_countdown = _rng.randi_range(PU_LOWER_BOUND,PU_UPPER_BOUND)
	_update_HUD()


## MRM TODO: This function should be renamed, as it is used for other interactions as well!
func on_interacted_with_furniture(action_id : int) -> void:
	#MRM: Duplicate of Objects cumbersome, and using the references of the array directly would
	#lead to errors. That's why I changed it, so it just creates a new instance each time:
	var current_action : EMC_Action = _create_action(action_id)
	
	var rejected_constraints : Array[String] = []
	for constraint_key: String in current_action.get_constraints_prior().keys():
		if not Callable(self, constraint_key).call():
			rejected_constraints.append(constraint_key)
	
	if rejected_constraints.size() >= 1:
		current_action.set_constraints_rejected(rejected_constraints)
		#MRM: Access via Index redundant
		#if self.gui_refs[0].get_type_gui() == "reject": 
			#self.gui_refs[0].show_gui(current_action)
		#else:
		_get_gui_ref_by_name("RejectGUI").show_gui(current_action)
	else:
		var gui_name := current_action.get_type_gui()
		_get_gui_ref_by_name(gui_name).show_gui(current_action)


func _get_gui_ref_by_name(p_name : String) -> EMC_GUI:
	for ref: EMC_ActionGUI in self.gui_refs:
		if ref.name == p_name:
			return ref
	return null


func _on_action_executed(action : EMC_Action) -> void:
	match get_current_day_period():
		EMC_DayPeriod.MORNING:
			self.current_day_cycle = EMC_DayCycle.new()
			self.current_day_cycle.morning_action = action
		EMC_DayPeriod.NOON:
			self.current_day_cycle.noon_action = action
		EMC_DayPeriod.EVENING:
			self.current_day_cycle.evening_action = action
			self.history.append(self.current_day_cycle)
			_seodGUI.open(self.current_day_cycle, false)
			_seodGUI.closed.connect(_on_seod_closed)
			if _avatar_ref.get_hunger_status() <= 0 || _avatar_ref.get_thirst_status() <= 0 || _avatar_ref.get_health_status() <= 0 :
				_avatar_life_status = false
			if get_current_day() >= self.max_day - 1 || !_avatar_life_status:
				_seodGUI.open(self.current_day_cycle, true)
				_seodGUI.closed.connect(_on_seod_closed_game_end)
			return
		#MRM: Defensive Programmierung: Ein "_" Fall sollte immer implementiert sein und Fehler werfen.
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()

func _on_seod_closed_game_end() -> void:
	_egGUI.open(self.history, _avatar_life_status)

func _on_seod_closed() -> void:
	self._period_cnt += 1
	_update_HUD()
	_check_pu_counter()


func get_current_day_cycle() -> EMC_DayCycle:
	return current_day_cycle #MRM: could be changed later to: self.history[get_current_day()]


func get_current_day_period() -> EMC_DayPeriod:
	return self._period_cnt % 3 as EMC_DayPeriod


func get_current_day() -> int:
	return floor(self._period_cnt / 3.0)


func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag " + str(get_current_day() + 1)
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()
	$HBoxContainer/RichTextLabelNutrition.text = str(_avatar_ref.get_unit_nutrition_status()) + "kcal"
	$HBoxContainer/RichTextLabelHydration.text = str(_avatar_ref.get_unit_hydration_status()) + "ml"
	$HBoxContainer/RichTextLabelHealth.text = str(_avatar_ref.get_unit_health_status()) + "%"
	
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
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", "PopUp 2 happening")
				_: 
					push_error("Unerwarteter Fehler PopUpAction")
		EMC_DayPeriod.NOON:
			var _counter_noon : int = _rng.randi_range(1, 2)
			match _counter_noon:
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", "PopUp 2 happening")
				_: 
					push_error("Unerwarteter Fehler PopUpAction")
		EMC_DayPeriod.EVENING: 
			var _counter_evening : int = _rng.randi_range(1, 2)
			match _counter_evening:
				1: result = EMC_PopUpAction.new(1001, "PopUp_1", { }, "Popup 1 happened", "PopUp 1 happening")
				2: result = EMC_PopUpAction.new(1002, "PopUp_2", { }, "Popup 2 happened", "PopUp 2 happening")
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
	_overworld_states_mngr_ref.set_furniture_state(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL, 
		_overworld_states_mngr_ref.get_furniture_state_maximum(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL))

######################################## CONSTRAINT METHODS ########################################
func constraint_cooking() -> bool:
	print("Constraint Cooking was checked!")
	#TODO: Electricity?
	##TODO: In the future: Else Gaskocher?
	return false


func constraint_not_evening() -> bool:
	return get_current_day_period() != EMC_DayPeriod.EVENING


########################################## CHANGE METHODS ##########################################
# "Changes" needed? See comment in Action.gd
func test_change() -> void:
	print("A change occurred!")

