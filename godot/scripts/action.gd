class_name EMC_Action

extends Node

signal executed(action : EMC_Action)

var ACTION_NAME : String 
var constrains_prior : Dictionary
# var constrains_content : Dictionary
var changes : Dictionary
var type_ui : String
var description : String

func _init(ACTION_NAME : String, constrains_prior : Dictionary,
		   changes : Dictionary, type_ui : String, description : String):
	self.ACTION_NAME = ACTION_NAME
	self.constrains_prior = constrains_prior
	self.changes = changes
	self.type_ui = type_ui
	self.description = description
