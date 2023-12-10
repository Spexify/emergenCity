class_name Action

extends Node

signal interacted(constrains, changes) 

## If get_avatar_rect is not set by parent, the game may crash
var get_avatar_rect : Callable

var ACTION_NAME : String 
var constrains : Dictionary
var changes : Dictionary
