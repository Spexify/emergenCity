extends Node
class_name EMC_PopupEventMngr

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var _popup_event_countdown : int
#PUEC = Pop-Up Event Countdown:
const PUEC_LOWER_BOUND : int = 3
const PUEC_UPPER_BOUND : int = 6

var _day_mngr: EMC_DayMngr
var _gui_mngr: EMC_GUIMngr

var _executable_constraints: EMC_ActionConstraints
var _executable_consequences: EMC_ActionConsequences


########################################## PUBLIC METHODS ##########################################
## Constructor
func _init(p_day_mngr: EMC_DayMngr, p_gui_mngr : EMC_GUIMngr) -> void:
	_day_mngr = p_day_mngr
	_gui_mngr = p_gui_mngr
	
	_rng.randomize()
	_popup_event_countdown = _rng.randi_range(PUEC_LOWER_BOUND, PUEC_UPPER_BOUND)


func set_constraints(p_constraints: EMC_ActionConstraints) -> void:
	_executable_constraints = p_constraints

func set_consequences(p_consqeuences: EMC_ActionConsequences) -> void:
	_executable_consequences = p_consqeuences

## 
func check_for_new_event() -> bool:
	#var _action : EMC_PopUpAction = JsonMngr.name_to_pop_up_action("GERHARD_KNOCKS")
	#_action.executed.connect(_day_mngr._on_action_executed)
	#_action.silent_executed.connect(_day_mngr._on_action_silent_executed)
	#_gui_mngr.queue_gui("PopUpGUI", [_action])
	#return true
	
	_popup_event_countdown -= 1
	if _popup_event_countdown == 0:
		var _action : EMC_PopUpAction = JsonMngr.get_pop_up_action(_executable_constraints)
		if _action != null:
			_action.executed.connect(_day_mngr._on_action_executed)
			_action.silent_executed.connect(_day_mngr._on_action_silent_executed)
			_gui_mngr.queue_gui("PopUpGUI", [_action])
			#await _puGUI.closed
		#Reset countdown
		_popup_event_countdown = _rng.randi_range(PUEC_LOWER_BOUND, PUEC_UPPER_BOUND)
		return true
	return false

func save() -> Dictionary:
	var data : Dictionary = {
		"count_down": _popup_event_countdown,
	}
	return data
	
func load_state(data : Dictionary) -> void:
	_popup_event_countdown = data.get("count_down", _popup_event_countdown)

########################################## PRIVATE METHODS #########################################
