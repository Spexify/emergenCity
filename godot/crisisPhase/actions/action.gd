class_name EMC_Action
## [EMC_Action] contains all infromation needed to describe a Action.
## It constains prior constraints ([member EMC_Action.constraints_prior]),
## associated GUI ([member EMC_Action.type_ui]) 
## and [member EMC_Action.changes] should the Action be performed.

extends Node

enum IDs{
	NO_ACTION = 0,
	CITY_MAP = 1,
	TELEPORTER_MARKET = 2, #obsolete
	REST = 3,
	COOKING = 4,
	RAINWATER_BARREL = 5,
	##1000s = PopupActions
	POPUP_0 = 1000,
	POPUP_1 = 1001,
	##2000s = StageChangeActions
	SC_HOME = 2000,
	SC_MARKET = 2001,
}

## This sigal will be emmited if the Action was performed 
## and is needed in [EMC_DayMngr] to recored a history of performed Actions.
signal executed(action : EMC_Action)
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
var _changes : Dictionary 
var _type_gui : String #deprecated??
var _description : String
var _performance_coin_value : int


func _init(action_ID: int, ACTION_NAME : String, constraints_prior : Dictionary,
		   changes : Dictionary, type_gui : String, description : String, performance_coin_value : int) -> void:
	self._action_ID = action_ID
	self._ACTION_NAME = ACTION_NAME
	self._constraints_prior = constraints_prior
	self._changes = changes
	self._type_gui = type_gui
	self._description = description
	self._performance_coin_value = performance_coin_value
	

func get_ACTION_NAME() -> String:
	return self._ACTION_NAME

func get_constraints_prior() -> Dictionary:
	return self._constraints_prior

func get_constraints_rejected() -> Array[String]:
	return self._constraints_rejected

func set_constraints_rejected(constraints_rejected: Array[String]) -> void:
	self._constraints_rejected = constraints_rejected

func get_changes() -> Dictionary:
	return self._changes

func get_type_gui() -> String:
	return self._type_gui

func get_description() -> String:
	return self._description
	
func get_performance_coin_value() -> int: 
	return self._performance_coin_value
	
func save() -> Dictionary:
	var data : Dictionary = {
		"action_ID": _action_ID,
		"ACTION_NAME": _ACTION_NAME,
		"description": _description,
	}
	return data
	
func load_state(data : Dictionary) -> void:
	_action_ID = data.get("action_ID")
	_ACTION_NAME = data.get("ACTION_NAME")
	_description = data.get("description")
	
static func empty_action() -> EMC_Action:
	return EMC_Action.new(NAN, "", {}, {}, "", "", 0)
