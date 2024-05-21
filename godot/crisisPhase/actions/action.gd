extends Node
class_name EMC_Action
## [EMC_Action] contains all infromation needed to describe a Action.
## It constains prior constraints ([member EMC_Action.constraints_prior]),
## associated GUI ([member EMC_Action.type_ui]) 
## and [member EMC_Action.changes] should the Action be performed.


enum IDs{
	NO_ACTION 		= 0,
	CITY_MAP 		= 1, #Interaction (never executes)
	COOKING 		= 2, 
	TAP_WATER 		= 3, #Interaction (never executes)
	REST 			= 4,
	RAINWATER_BARREL = 5,
	SHOWER 			= 6,
	BBK_LINK		= 7,
	ELECTRIC_RADIO	= 8,
	CRANK_RADIO		= 9,
	##1000s = PopupActions
	POPUP_0 = 1000,
	POPUP_1 = 1001,
	##2000s = StageChangeActions
	SC_HOME = 2000,
	SC_MARKET = 2001,
	SC_TOWNHALL = 2002,
	SC_PARK = 2003,
	SC_GARDENHOUSE = 2004,
	SC_ROWHOUSE = 2005,
	SC_MANSION = 2006,
	SC_PENTHOUSE = 2007,
	SC_APARTMENT_MERT = 2008, #Muss in JSON ausgelagert werden
	SC_APARTMENT_CAMPER = 2009, #Muss in JSON ausgelagert werden
	SC_APARTMENT_AGATHE = 2010 #Muss in JSON ausgelagert werden
}

## This sigal will be emmited if the Action was performed 
## and is needed in [EMC_DayMngr] to recored a history of performed Actions.
signal executed(action : EMC_Action)
signal silent_executed(action : EMC_Action)

## The ID-integer associated with this action
var _action_ID : int
## Name associated with this Action, needed in [EMC_End_of_Day_Summary].
var _ACTION_NAME : String #MRM: Why capital case, if not a constant?

## A dictonary contaning all prior constraints before showing the associated [EMC_GUI].
## Where the key of the [Dictionary] is the String name of a Function and the value the Parameters for it.
var _constraints_prior : Dictionary
# var constraints_content : Dictionary
var _constraints_rejected : Array[String]
## A dictonary contaning all changes to be applied schould the Action be performed.
## In the same Format as [member EMC_Action.constraints_prior]
#MRM: Still needed? Now we designed the system in that way, that the GUI is responsible for any changes:
var _consequences : Dictionary #MRM: Renamed changes to consequences, because "changes" can mean anything
var _type_gui : String #deprecated??
var _description : String
var _performance_coin_value : int
var _progresses_day_period: bool
var _prompt: String
var _sound : String


func _init(action_ID: int, ACTION_NAME : String, constraints_prior : Dictionary,
p_consequences : Dictionary, type_gui : String, description : String,
p_prompt: String = "", performance_coin_value : int = 0,
p_progresses_day_period: bool = true, p_sound : String = "") -> void:
	self._action_ID = action_ID
	self._ACTION_NAME = ACTION_NAME
	self._constraints_prior = constraints_prior
	self._consequences = p_consequences
	self._type_gui = type_gui
	self._description = description
	self._prompt = p_prompt
	self._performance_coin_value = performance_coin_value
	self._progresses_day_period = p_progresses_day_period
	self._sound = p_sound


func get_ID() -> int:
	return _action_ID


func get_ACTION_NAME() -> String:
	return self._ACTION_NAME


func get_constraints_prior() -> Dictionary:
	return self._constraints_prior


func get_constraints_rejected() -> Array[String]:
	return self._constraints_rejected


func set_constraints_rejected(constraints_rejected: Array[String]) -> void:
	self._constraints_rejected = constraints_rejected


func get_consequences() -> Dictionary:
	return self._consequences


func get_type_gui() -> String:
	return self._type_gui


func get_description() -> String:
	return self._description


func get_prompt() -> String:
	return _prompt


func get_performance_coin_value() -> int: 
	return self._performance_coin_value


func progresses_day_period() -> bool:
	return _progresses_day_period


## Disclaimer: godoIf a consequence with the same key already exists, it is overwritten!
func add_consequence(p_key: String, p_param: Variant) -> void:
	_consequences[p_key] = p_param

func play_sound(start : float = 0, pitch : float = 1) -> AudioStreamPlayer:
	return SoundMngr.play_sound(_sound, start, pitch)

func save() -> Dictionary:
	var data : Dictionary = {
		#"type": "action",
		"action_ID": _action_ID,
		#"ACTION_NAME": _ACTION_NAME,
		#"description": _description,
		#"consequences": EMC_ActionConsequences.to_json(_consequences),
	}
	return data

func load_state(data : Dictionary) -> void:
	_action_ID = data.get("action_ID")
	
	if JsonMngr._dict_actions.has(_action_ID):
		load_from_dict(JsonMngr._dict_actions.get(_action_ID))

func load_from_dict(data : Dictionary) -> void:
	_action_ID = data.get("id")
	_ACTION_NAME = data.get("name", "")
	_constraints_prior = data.get("constraints", {})
	_consequences = data.get("consequences",{})
	_type_gui = data.get("type_gui", "")
	_description = data.get("description", "")
	_performance_coin_value = data.get("e_coins", 0)
	_progresses_day_period = data.get("progresses_day_period", true)
	_sound = data.get("sound", "")
	
	_prompt = data.get("prompt", "")

static func empty_action() -> EMC_Action:
	return EMC_Action.new(NAN, "", {}, {}, "", "")

static func from_dict(data : Dictionary) -> EMC_Action:
	var action_id : int = data.get("id")
	var action_name : String = data.get("name", "")
	var constraints : Dictionary = data.get("constraints", {})
	var consequences : Dictionary = data.get("consequences",{})
	var type_gui : String = data.get("type_gui", "")
	var description : String = data.get("description", "")
	var e_coin : int = data.get("e_coins", 0)
	var p_progresses_day_period : bool = data.get("progresses_day_period", true)
	var sound : String = data.get("sound", "")
	
	var prompt : String = data.get("prompt", "")
	
	return EMC_Action.new(action_id, action_name, constraints, consequences, type_gui, description, prompt, e_coin, p_progresses_day_period, sound)
