class_name EMC_Action
## [EMC_Action] contains all infromation needed to describe a Action.
## It constains prior constrains ([member EMC_Action.constrains_prior]),
## associated GUI ([member EMC_Action.type_ui]) 
## and [member EMC_Action.changes] should the Action be performed.

extends Node

## This sigal will be emmited if the Action was performed 
## and is needed in [EMC_DayMngr] to recored a history of performed Actions.
signal executed(action : EMC_Action)

## Name associated with this Action, needed in [EMC_End_of_Day_Summary].
var _ACTION_NAME : String 

## A dictonary contaning all prior constrains before showing the associated [EMC_GUI].
## Where the key of the [Dictionary] is the String name of a Function and the value the Parameters for it.
var _constrains_prior : Dictionary
# var constrains_content : Dictionary
var _constrains_rejected : Array[String]
## A dictonary contaning all changes to be applied schould the Action be performed.
## In the same Format as [member EMC_Action.constrains_prior]
var _changes : Dictionary
var _type_ui : String
var _description : String

func _init(ACTION_NAME : String, constrains_prior : Dictionary,
		   changes : Dictionary, type_gui : String, description : String):
	self._ACTION_NAME = ACTION_NAME
	self._constrains_prior = constrains_prior
	self._changes = changes
	self._type_ui = type_gui
	self._description = description
