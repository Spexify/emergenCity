class_name EMC_DialogueMngr
extends Node

var _action_constrains : EMC_ActionConstraints
var _action_consequences : EMC_ActionConsequences
var _day_mngr : EMC_DayMngr
var _gui_mngr : EMC_GUIMngr

var _dialogue_dictionary : Dictionary
var _current_dictionary : Dictionary

const MAX_OPTION_COUNT : int = 3

func _init(p_action_constrains : EMC_ActionConstraints, p_action_consequences : EMC_ActionConsequences, p_day_mngr : EMC_DayMngr, p_gui_mngr : EMC_GUIMngr) -> void:
	_action_constrains = p_action_constrains
	_action_consequences = p_action_consequences
	_day_mngr = p_day_mngr
	_gui_mngr = p_gui_mngr
	
	_dialogue_dictionary = JsonMngr.get_dialogues()
	
func next_dialogue(dialogue : Dictionary, top_level : bool = false) -> Array[Dictionary]:
	if dialogue.is_empty():
		return [{}]
	
	var priority: bool = false
	
	var keys : Array[Dictionary] = []
	var weights : Array[float] = []
	
	for key : String in dialogue.keys():
		if top_level and key.begins_with("#"):
			continue 
		
		var raw_dialogue_option : Variant = dialogue.get(key)
		var dialogue_option : Dictionary
		if typeof(raw_dialogue_option) == TYPE_STRING:
			dialogue_option = _current_dictionary.get(key) if not _current_dictionary.is_empty() else {}
		else:
			dialogue_option = raw_dialogue_option
			
		var result : bool = true
		var conditions : Variant = dialogue_option.get("conditions", {})
		if typeof(conditions) == TYPE_DICTIONARY:
			for cond : String in conditions:
				result = result and (_action_constrains.call(cond, conditions.get(cond)) == EMC_ActionConstraints.NO_REJECTION)
			result = result and (dialogue_option.get("cooldown_end", 0) <= _day_mngr.get_period_count())
		elif typeof(conditions) == TYPE_ARRAY:
			for cond: Dictionary in conditions:
				if not cond.has("method"):
					printerr("Dialog condition missing method name!!!")
				result = result and (_action_constrains.call(cond["method"], cond) == EMC_ActionConstraints.NO_REJECTION)
			result = result and (dialogue_option.get("cooldown_end", 0) <= _day_mngr.get_period_count())
		
		if result:
			if not dialogue_option.has("priority") and not priority:
				keys.append(dialogue_option)
				weights.append(dialogue_option.get("weight", 1))
			
			if dialogue_option.has("priority"):
				priority = true
				keys.append(dialogue_option)
				weights.append(dialogue_option.get("weight", 1))
	
	var options : Array[Dictionary]
	var count : int
	if not keys[0].has("prompt"):
		count = 1
	elif keys.size() >= MAX_OPTION_COUNT:
		count = MAX_OPTION_COUNT
	else:
		count = keys.size()
		
	options.assign(EMC_Util.pick_weighted_random(keys, weights, count))
	return options
	
func execute_dialoge_consequences(dialogue : Dictionary) -> void:
	var consequences : Dictionary = EMC_ActionConsequences.from_json(dialogue.get("consequences", {}))
	for cons : String in consequences:
		if _action_consequences.has_method(cons):
			_action_consequences.call(cons, consequences.get(cons))
		else:
			printerr("There is no consequence '" + cons + "'")
	
func update_cooldown(dialogue : Dictionary) -> bool:
	if dialogue.has("cooldown"):
		dialogue["cooldown_end"] = _day_mngr.get_period_count() + dialogue["cooldown"]
		return true
	return false
	
func start_dialogue_headless(stage_name : String, actor_name : String) -> Dictionary:
	_current_dictionary = (_dialogue_dictionary.get(stage_name, {}) as Dictionary).get(actor_name.to_lower(), {})
	if _current_dictionary.is_empty():
		push_error("There is no dialogue for " + actor_name.to_lower() + " on stage " + stage_name)
		return {}
	
	var dialogue := next_dialogue(_current_dictionary, true)[0]
	update_cooldown(dialogue)
	return dialogue
	
func _on_dialogue_initiated(stage_name : String, actor_name : String) -> void:
	var dialogue := start_dialogue_headless(stage_name, actor_name)
	_gui_mngr.request_gui("DialogueGui", [dialogue])
