extends Node

@onready var uncast_actions : Array[Node] = get_children()

enum DayTime {MORNING=0, NOON=1, NIGHT=2}

var current_time : DayTime = DayTime.MORNING
var current_day : int = 0

var parent : Node2D
var get_avatar_rect : Callable

func _index_actions():
	var actions = []
	for uncast in uncast_actions:
		actions.append(uncast as Action)
	
	for action in actions:
		action.interacted.connect(_handel_actions)
		action.get_avatar_rect = get_avatar_rect

func _handel_actions(constrains, changes):
	var allowed : bool = true
	for constrain_key in constrains.keys():
		allowed = allowed && Callable(parent, constrain_key).call(constrains[constrain_key]) 
	
	if allowed:
		current_time += 1
		
		if current_time >= DayTime.size():
			current_day += 1
			current_time = 0

		print("Day: %d, %s" % [current_day, DayTime.keys()[current_time]])
		
		for change_key in changes.keys():
			Callable(parent, change_key).call(changes[change_key])
