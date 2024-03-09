extends Node
class_name EMC_PopupEventMngr

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _popup_event_countdown : int
#PUEC = Pop-Up Event Countdown:
const PUEC_LOWER_BOUND : int = 3
const PUEC_UPPER_BOUND : int = 6

var _day_mngr: EMC_DayMngr
var _puGUI: EMC_PopUpGUI
var _executable_constraints: EMC_ActionConstraints
var _executable_consequences: EMC_ActionConsequences


########################################## PUBLIC METHODS ##########################################
## Constructor
func _init(p_day_mngr: EMC_DayMngr, p_puGUI : EMC_PopUpGUI, p_constraints: EMC_ActionConstraints,
p_consqeuences: EMC_ActionConsequences) -> void:
	_day_mngr = p_day_mngr
	_puGUI = p_puGUI
	_executable_constraints = p_constraints
	_executable_consequences = p_consqeuences
	
	_rng.randomize()
	_popup_event_countdown = _rng.randi_range(PUEC_LOWER_BOUND, PUEC_UPPER_BOUND)


########################################## PRIVATE METHODS #########################################
func _on_day_mngr_period_ended(p_new_period: EMC_DayMngr.DayPeriod) -> void:
	_popup_event_countdown -= 1
	if _popup_event_countdown == 0:
		var _action : EMC_PopUpAction = JsonMngr.get_pop_up_action(_executable_constraints)
		if _action != null:
			_action.executed.connect(_day_mngr._on_action_executed)
			_action.silent_executed.connect(_day_mngr._on_action_silent_executed)
			_puGUI.open(_action)
		#Reset countdown
		_popup_event_countdown = _rng.randi_range(PUEC_LOWER_BOUND, PUEC_UPPER_BOUND)
