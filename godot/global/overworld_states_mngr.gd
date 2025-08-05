extends Node
class_name EMC_OverworldStatesMngr

signal change(changes : String)

const SAVE_FILE = "user://OSM.res"

#region Enums
enum Difficulty{
	TUTORIAL = 3,
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}

const state_to_icon: Dictionary = {
	"MobileNetState.ONLINE" : preload("res://assets/GUI/icons/online_icon.png"),
	"MobileNetState.OFFLINE" : preload("res://assets/GUI/icons/offline_icon.png"),
	"ElectricityState.NONE" : preload("res://assets/GUI/icons/no_power_icon.png"),
	"ElectricityState.UNLIMITED" : preload("res://assets/GUI/icons/power_icon.png"),
	"WaterState.NONE" : preload("res://assets/GUI/icons/no_water_icon.png"),
	"WaterState.DIRTY" : preload("res://assets/GUI/icons/dirty_water_icon.png"),
	"WaterState.CLEAN" : preload("res://assets/GUI/icons/water_icon.png"),
	"FoodContaminationState.NONE" : preload("res://assets/GUI/icons/food_icon.png"),
	"FoodContaminationState.FOOD_SPOILED" : preload("res://assets/GUI/icons/food_contaminated_icon.png"),
	"IsolationState.NONE" : preload("res://assets/GUI/icons/no_power_icon.png"),
	"IsolationState.LIMITED_PUBLIC_ACCESS" : preload("res://assets/GUI/icons/no_power_icon.png"),
	"IsolationState.ISOLATION" : preload("res://assets/GUI/icons/no_power_icon.png"),
}

@export var state_to_descr: Dictionary = {
	"MobileNetState.ONLINE" : "Du hast eine Verbinung zum Internet",
	"MobileNetState.OFFLINE" : "Das Internet ist ausgefallen",
	"ElectricityState.NONE" : "Der Strom ist ausgefallen",
	"ElectricityState.UNLIMITED" : "Du hast Strom",
	"WaterState.NONE" : "Das Wasser ist ausgefallen",
	"WaterState.DIRTY" : "Das Wasser ist verdreckt",
	"WaterState.CLEAN" : "Du hast sauberes Wasser",
	"FoodContaminationState.NONE" : "",
	"FoodContaminationState.FOOD_SPOILED" : "",
	"IsolationState.NONE" : "",
	"IsolationState.LIMITED_PUBLIC_ACCESS" : "",
	"IsolationState.ISOLATION" : "",
}

var _upgrades: Array[EMC_Upgrade]

var _difficulty_crisis : Difficulty
var _run_length : int


func _ready() -> void:
	add_to_group("Save", true)
	
func reset() -> void:
	#Scenario
	clear_crisis_description()
	
	#State
	facility_states = FACILITY_STATES_DEFAULT.duplicate(true)
	facility_effective_states = {}
	for state: String in facility_states:
		facility_effective_states[state] = facility_states[state]["default"]
	modifiers = BASE_MODIFIERS.duplicate(true)
	
	# Quest
	clear_quest()
	
	# NPC
	_npc_intention_back.clear()
	clear_npc_intention()
	
	# Dialoge
	clear_dialoge_states()

func set_crisis_difficulty(p_run_length : int = 3, p_difficulty_crisis : Difficulty = Difficulty.EASY) -> void:
	_difficulty_crisis = p_difficulty_crisis
	_run_length = p_run_length

func get_crisis_length() -> int:
	return _run_length

func get_difficulty() -> Difficulty:
	return _difficulty_crisis

############################################Scenario################################################
#region Scenario
var _crisis_description : Dictionary

## Returns scenario name
func get_scenario_names() -> Array[String]:
	var result : Array[String]
	result.assign(_crisis_description.keys())
	return result

func get_description_by_name(scenario : String) -> Dictionary:
	if _crisis_description.has(scenario):
		return _crisis_description[scenario]
	else:
		return {"Error" : "No such Scenario"}
		
func get_description_by_index(index : int) -> Dictionary:
	return _crisis_description[_crisis_description.keys()[index]]
	
func get_description() -> Dictionary:
	return _crisis_description
	
func set_description(p_crisis_description : Dictionary) -> void:
	_crisis_description = p_crisis_description 
	
func add_scenario_notification(scenario_name : String, p_notification : String) -> void:
	if not _crisis_description.has(scenario_name):
		_crisis_description[scenario_name] = {"notification": p_notification}
	else:
		_crisis_description[scenario_name]["notification"] = p_notification
	
func add_scenario_entry(scenario_name : String, index : String, desc : String, states : Array[Dictionary]) -> void:
	if not _crisis_description.has(scenario_name):
		return
	_crisis_description[scenario_name][index] = { "desc": desc, "states": states }
	
func remove_scenario_by_name(scenario_name : String) -> void:
	if _crisis_description.has(scenario_name):
		_crisis_description.erase(scenario_name)
		
func remove_scenario_entry(scenario_name : String, index : String) -> void:
	if _crisis_description.has(scenario_name):
		_crisis_description[scenario_name].erase(index)

## Returns notification for radio
func get_notification() -> Array[String]:
	var result : Array[String]
	for description : Dictionary in _crisis_description.values():
		result.append(description["notification"])
		result.append_array(description.values().slice(1).map(func (dict : Dictionary) -> String: return dict["desc"]))
	return result
	
func clear_crisis_description() -> void:
	_crisis_description.clear()
#endregion

#############################################States#################################################

#region States

const STATE_TRANSLATOR: Dictionary = {
	"ElectricityState": {"NONE": 0, "UNLIMITED": 1},
	"WaterState": {"NONE": 0, "DIRTY": 1, "CLEAN": 2},
	"MobileNetState": {"OFFLINE": 0, "ONLINE": 1}
}

const FACILITY_STATES_DEFAULT: Dictionary = {
	"ElectricityState": {"default": 1},
	"WaterState": {"default": 2},
	"MobileNetState": {"default": 1}
}

var facility_states: Dictionary = {
	"ElectricityState": {"default": 1},
	"WaterState": {"default": 2},
	"MobileNetState": {"default": 1}
}

var facility_effective_states: Dictionary = {
	"ElectricityState": 1,
	"WaterState": 2,
	"MobileNetState": 1
}

func add_state_layer_int(state: String, id: String, value: int) -> void:
	if not facility_states.has(state):
		facility_states[state] = {}
	facility_states[state]["stuff"] = value
	
	facility_effective_states[state] = _calculate_effective_state(state)
	
	change.emit(state)

func add_state_layer_str(state: String, id: String, value: String) -> void:
	add_state_layer_int(state, id, STATE_TRANSLATOR[state][value])
	
func remove_state_layer(state: String, id: String) -> void:
	if facility_states.has(state):
		facility_states[state].erase(id)
		
	facility_effective_states[state] = _calculate_effective_state(state)

func _calculate_effective_state(state: String) -> int:
	var values: Array[int]
	values.assign(facility_states.get(state, {}).values())
	if not values.is_empty():
		return values.min()
	return -1

func get_effective_state_int(state: String) -> int:
	return facility_effective_states.get(state, -1)

func get_effective_state_str(state: String) -> String:
	if facility_effective_states.has(state):
		return STATE_TRANSLATOR[state].find_key(facility_effective_states[state])
	return "NULL"
	
func is_effective_state_eq(state: String, value: String) -> bool:
	return get_effective_state_int(state) == STATE_TRANSLATOR[state][value]

func is_effective_state_neq(state: String, value: String) -> bool:
	return get_effective_state_int(state) != STATE_TRANSLATOR[state][value]
	
func is_effective_state_lt(state: String, value: String) -> bool:
	return get_effective_state_int(state) < STATE_TRANSLATOR[state][value]
	
func is_effective_state_gt(state: String, value: String) -> bool:
	return get_effective_state_int(state) > STATE_TRANSLATOR[state][value]

#endregion

#region flags
var flags: Dictionary = {
	"NoEntry": {}
}

func add_flag_layer(state: String, flag: String) -> void:
	if not flags.has(state):
		flags[state] = {}
	if flags[state].has(flag):
		flags[state][flag] += 1
	else:
		flags[state][flag] = 1
	
func remove_flag_layer(state: String, flag: String) -> void:
	if flags.has(state) and flags[state].has(flag):
		flags[state][flag] -= 1
		
		if flags[state][flag] <= 0:
			flags[state].erase(flag)

func get_flags(state: String) -> Array[String]:
	if flags.has(state):
		return flags[state].keys()
	return ["NULL"]
	
func has_flag(state: String, flag: String) -> bool:
	return flags.get(state, {}).has(flag)

func has_not_flag(state: String, flag: String) -> bool:
	return not flags.get(state, {}).has(flag)	
	
func has_any_flag(p_state: String, p_flags: Array[String]) -> bool:
	var state: Dictionary = flags.get(p_state, {})
	if state.is_empty():
		return p_flags.is_empty()
	for flag in p_flags:
		if state.has(flag):
			return true
	return false
	
func has_all_flag(state: String, p_flags: Array[String]) -> bool:
	return flags.get(state, {}).has_all(p_flags)

#endregion

#region modifiers

const BASE_MODIFIERS: Dictionary = {
	"food_decay_rate": 0.6
}

var modifiers: Dictionary = {
	"food_decay_rate": 0.6
}

func add_modifier(state: String, value: float) -> void:
	if modifiers.has(state):
		modifiers[state] += value
	else:
		modifiers[state] = BASE_MODIFIERS.get(state, 0) + value

func remove_modifier(state: String) -> void:
	modifiers.erase(state)

func get_modifier(state: String) -> float:
	return modifiers.get(state, BASE_MODIFIERS.get(state, INF))

#endregion

func ask_OSM_api(dict: Dictionary) -> bool:
	if dict.has("state"):
		if dict.has("is"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is"]] == get_effective_state_int(state)
		elif dict.has("is_not"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_not"]] !=  get_effective_state_int(state)
		elif dict.has("is_gt"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_gt"]] < get_effective_state_int(state)
		elif dict.has("is_lt"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_lt"]] > get_effective_state_int(state)
	elif dict.has("flag"):
		if dict.has("has"):
			return has_flag(dict["flag"], dict["has"])
		elif dict.has("has_not"):
			return has_not_flag(dict["flag"], dict["has_not"])
		elif dict.has("has_any"):
			return has_any_flag(dict["flag"], dict["has_any"])
		elif dict.has("has_all"):
			return has_all_flag(dict["flag"], dict["has_all"])
	
	return false

func apply_effect(data: Dictionary) -> void:
	if data.has_all(["state", "value", "layer"]):
		add_state_layer_str(data["state"], data["layer"], data["value"])
	elif data.has_all(["flag", "value"]):
		add_flag_layer(data["flag"], data["value"])
	elif data.has_all(["modifier", "value"]):
		add_modifier(data["modifier"], data["value"])

func remove_effect(data: Dictionary) -> void:
	if data.has_all(["state", "layer"]):
		remove_state_layer(data["state"], data["layer"])
	elif data.has_all(["flag", "value"]):
		remove_flag_layer(data["flag"], data["value"])
	elif data.has_all(["modifier", "value"]):
		add_modifier(data["modifier"], -data["value"])


func get_every_state_as_name() -> Array[String]:
	return [
		"WaterState." + get_effective_state_str("WaterState"),
		"ElectricityState." + get_effective_state_str("ElectricityState"),
		"MobileNetState." + get_effective_state_str("MobileNetState"),
		#"FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state),
		#"IsolationState." + IsolationState.find_key(_isolation_state)
	]

############################################Dialogue################################################
#region Dialogue
var _dialogue_states : Dictionary

func set_dialogue_state(state_name : String, value : Variant) -> void:
	_dialogue_states[state_name] = value
	
func is_dialogue_state(state_nane : String, value : Variant) -> bool:
	if _dialogue_states.has(state_nane):
		return typeof(_dialogue_states[state_nane]) == typeof(value) and _dialogue_states[state_nane] == value
	return false
	
func clear_dialoge_states() -> void:
	_dialogue_states.clear()
#endregion

############################################Furniture###############################################
#region Furniture

func set_upgrades(upgrades : Array[EMC_Upgrade]) -> void:
	_upgrades = upgrades

## TODO: more efficent version
func has_upgrade(id: EMC_Upgrade.IDs) -> bool:
	return id in _upgrades.map(func (up: EMC_Upgrade) -> int: return up.get_id())

func get_upgrades() -> Array[EMC_Upgrade]:
	return _upgrades

func get_upgardes_id() -> Array[int]:
	var result: Array[int]
	result.assign(_upgrades.map(func(upgrade: EMC_Upgrade) -> int: return upgrade.get_id()))
	return result

func get_upgrade_if_equipped(p_ID: EMC_Upgrade.IDs) -> EMC_Upgrade:
	for upgrade in _upgrades:
		if upgrade.get_id() == p_ID:
			return upgrade
	return null

func get_furniture_state(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state()
	push_error("Upgrade nicht ausgerüstet!")
	return -1

func set_furniture_state(p_upgrade_id: EMC_Upgrade.IDs, new_state: int) -> void:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			upgrade.set_state(new_state)
	push_error("Upgrade nicht ausgerüstet!")

func get_furniture_state_maximum(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state_maximum()
	push_error("Upgrade nicht ausgerüstet!")
	return -1
#endregion
	
#############################################Quest##################################################
#region Quest
var active_quests: Dictionary = {}

## Returns wether a quest is currently active
## Does not return the stage of the quest
func has_quest(id: String) -> bool:
	return id in active_quests

## Adds a new quest or overrides the stage
func add_quest(id: String, stage: int = 1) -> void:
	active_quests[id] = stage
	#print(active_quests)

## Returns the current stage of the quest
## Should only be called after confirming quest exists
## with has_quest
func get_quest_stage(id: String) -> int:
	return active_quests[id]
	
## Removes a quest
func remove_quest(id: String) -> void:
	active_quests.erase(id)
	
## Regulate number of cocurrent quest
func next_quest() -> bool:
	return active_quests.size() < 3

func clear_quest() -> void:
	active_quests.clear()
#endregion

##############################################NPC###################################################
#region NPC

# Format: {NPC: ACTION_ID}
var _npc_intention: Dictionary
var _npc_intention_back: Dictionary
var _npc_intention_changed: bool = false

func add_npc_intention(npc: String, action_id: String) -> void:
	_npc_intention_back[npc] = action_id
	if _npc_intention.get(npc) != action_id:
		_npc_intention_changed = true

func npc_intention_swap() -> void:
	_npc_intention = _npc_intention_back.duplicate()
	_npc_intention_back.clear()
	_npc_intention_changed = false

func clear_npc_intention() -> void:
	_npc_intention.clear()
	_npc_intention_changed = false
#endregion

############################################Save/Load###############################################

## Save function called to get all relevant information. This is used for Saving/loading
func save() -> Dictionary:
	var data: EMC_AllRes = EMC_AllRes.new()
	data.add_res("difficulty_crisis", _difficulty_crisis)
	data.add_res("run_length", _run_length)
	data.add_res("crisis_description", _crisis_description)
	data.add_res("facility_effective_states", facility_effective_states)
	data.add_res("facility_states", facility_states)
	data.add_res("flags", flags)
	data.add_res("modifiers", modifiers)
	data.add_res("upgrades", _upgrades)
	
	ResourceSaver.save(data, SAVE_FILE)
	
	return {"node_path": get_path()}

## Load all relevant information. This is used for Saving/loading
func load_state(p_data : Dictionary) -> void:
	var data : EMC_AllRes = EMC_AllRes.load_res(SAVE_FILE)
	
	var p_difficulty_crisis : Difficulty = data.get_res("difficulty_crisis")
	var p_run_length : int = data.get_res("run_length")
	
	set_crisis_difficulty(p_run_length, p_difficulty_crisis)
	
	facility_effective_states = data.get_res("facility_effective_states")
	facility_states = data.get_res("facility_states")
	flags = data.get_res("flags")
	modifiers = data.get_res("modifiers")
	
	var p_crisis_description : Dictionary = data.get_res("crisis_description")
	
	set_description(p_crisis_description)
	
	var upgrades: Array[EMC_Upgrade]
	upgrades.assign(data.get_res("upgrades", []))
	set_upgrades(upgrades)
