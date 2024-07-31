extends Control
class_name EMC_CrisisMngr

## Improvement idea: Move curr EMC_CrisisScenario reference to here from OverworldStateMngr

var _day_mngr :  EMC_DayMngr
var _inventory : EMC_Inventory
var _gui_mngr : EMC_GUIMngr
var _max_day : int
var _difficulty : OverworldStatesMngr.Difficulty

# Sorted Array (sorted according to the end of the crisis > )
var _current_crisis : Array[Dictionary] = []
# Sorted Array (sorted according to the beginning of the crisis > )
var _next_crisis : Array[Dictionary] = []
var _days_since_last_crisis : int = 0

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var CRISIS : Array[Dictionary] = [
	{
		"name" : "0.Tutorial.0",
		"difficulty" : OverworldStatesMngr.Difficulty.TUTORIAL,
		"weight" : 1,
		"notification" : "",
		"fcount" : [1, 1],
		"following" : [{
			"name" : "0.Turorial.1",
			"weight" : 1,
			"delay" : [0,  0],
			"states" : ["ElectricityState.NONE"],
			"desc" : "Kein Strom",
			"decay" : [4, 6],
		}]
	},
	{
		"name" : "0.Hochwasser.0",
		"difficulty" : OverworldStatesMngr.Difficulty.EASY,
		"weight" : 1,
		"notification" : "Aufgrund von Tage langen Regen ...",
		"fcount" : [1, 1],
		"following" : [{
			"name" : "0.Hochwasser.1",
			"weight" : 1,
			"delay" : [0, 0],
			"states" : ["WaterState.DIRTY"],
			"desc" : "Das Wasser ist verschmutzt.",
			"decay" : [4, 6],
			"fcount" : [1, 2],
			"following": [{
				"name" : "0.Hochwasser.2",
				"weight" : 5,
				"delay" : [2, 3],
				"states" : ["ElectricityState.NONE"],
				"desc" : "Aufgrund des Hochwassers ist der Strom ausgefallen.",
				"decay" : [2, 3]
			}, {
				"name" : "0.Hochwasser.3",
				"weight" : 2,
				"delay" : [2, 4],
				"states" : ["MobileNetState.OFFLINE"],
				"desc" : "Aufgrund des Hochwassers ist das Mobilfunknext eingebrochen.",
				"decay" : [2, 3]
			}]
		}]
	},
]

func setup(p_backpack : EMC_Inventory, p_gui_mngr: EMC_GUIMngr, p_day_mngr: EMC_DayMngr) -> void: 
	_rng.randomize()
	_inventory = p_backpack
	_gui_mngr = p_gui_mngr
	_day_mngr = p_day_mngr

	_max_day = OverworldStatesMngr.get_crisis_length()
	_difficulty = OverworldStatesMngr.get_difficulty()
		
############################# GETTERS AND SETTERS ##################################################

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day

########################################## PUBLIC METHODS ##########################################


## Reduce countdowns and check the new states
## Returns the value that showed_new_crises() returns
func check_crisis_status() -> void:
	if _current_crisis.is_empty() and _next_crisis.is_empty():
		match _difficulty:
			OverworldStatesMngr.Difficulty.TUTORIAL:
				var tutorial_crisis : Array[Dictionary] = [CRISIS[0]]
				_generate_crisis(tutorial_crisis)
			OverworldStatesMngr.Difficulty.EASY:
				if _days_since_last_crisis >= _rng.randi_range(0, 3):
					var easy_crisis : Array[Dictionary] = CRISIS.filter(func (dict : Dictionary) -> bool: return dict["difficulty"] == OverworldStatesMngr.Difficulty.EASY)
					_generate_crisis(easy_crisis)
			OverworldStatesMngr.Difficulty.MEDIUM:
				if _days_since_last_crisis >= _rng.randi_range(0, 2):
					var medium_crisis : Array[Dictionary] = CRISIS.filter(func (dict : Dictionary) -> bool: return dict["difficulty"] <= OverworldStatesMngr.Difficulty.MEDIUM)
					_generate_crisis(medium_crisis)
			OverworldStatesMngr.Difficulty.HARD:
				if _days_since_last_crisis >= _rng.randi_range(0, 1):
					var hard_crisis : Array[Dictionary] = CRISIS.filter(func (dict : Dictionary) -> bool: return dict["difficulty"] <= OverworldStatesMngr.Difficulty.HARD)
					_generate_crisis(hard_crisis)
	
	for index : int in range(_current_crisis.size()-1, -1, -1):
		if _current_crisis[index]["stop"] <= _day_mngr.get_period_count():
			## state
			if _current_crisis[index].has("states"):
				for state : Variant in _current_crisis[index]["states"]:
					OverworldStatesMngr.sub_any_state_by_name(state)
			## description
			var crisis_name : String = _current_crisis[index]["name"].get_basename()
			var desc_nr : String = _current_crisis[index]["name"].get_extension()
			if _current_crisis[index].has("desc"):
				OverworldStatesMngr.remove_scenario_entry(crisis_name, desc_nr)
			if _current_crisis[index].has("notification"):
				OverworldStatesMngr.remove_scenario_by_name(crisis_name)
			_current_crisis.remove_at(index)
		else:
			break
	
	for index : int in range(_next_crisis.size()-1, -1, -1):
		if _next_crisis[index]["start"] <= _day_mngr.get_period_count():
			var jj : int = _current_crisis.bsearch_custom(_next_crisis[index], self.sort_stop_descending)
			_current_crisis.insert(jj, _next_crisis[index])
			## state
			if _next_crisis[index].has("states"):
				for state : Variant in _next_crisis[index]["states"]:
					OverworldStatesMngr.add_any_state_by_name(state)
					
					if (state is OverworldStatesMngr.FoodContaminationState 
					and (state as  OverworldStatesMngr.FoodContaminationState) == OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED):
						_inventory.spoil_all_items()
			## description
			var crisis_name : String = _next_crisis[index]["name"].get_basename()
			var desc_nr : String = _next_crisis[index]["name"].get_extension()
			if _next_crisis[index].has("desc"):
				OverworldStatesMngr.add_scenario_entry(crisis_name, desc_nr,
				_next_crisis[index]["desc"], _next_crisis[index]["states"])
			## notification
			if _next_crisis[index].has("notification"):
				OverworldStatesMngr.add_scenario_notification(crisis_name,  _next_crisis[index]["notification"])
			_next_crisis.remove_at(index)
		else:
			break
	
	if _current_crisis.is_empty():
		_days_since_last_crisis += 1
	else:
		_days_since_last_crisis = 0
	
	#print("Current Crisis:")
	#print(_current_crisis)
	#print("Next Crisis:")
	#print(_next_crisis)
	##print(_day_mngr.get_period_count())
	#print(OverworldStatesMngr._crisis_description)

########################################## PRIVATE METHODS #########################################
func _generate_crisis(choices : Array[Dictionary]) -> void:
	var weights : Array[float]
	weights.assign(choices.map(func(dict : Dictionary) -> float: return dict.get("weight")))
	var scenario : Dictionary = Global.pick_weighted_random(choices, weights, 1)[0]
	
	_gen_next_crisis(scenario, _day_mngr.get_period_count(), 0, true)
	
func _gen_next_crisis(scenario : Dictionary, start : int, stop : int, root : bool = false) -> int:
	if not root:
		# start with delay from parent crisis
		start = start + _rng.randi_range(scenario["delay"][0], scenario["delay"][1])
		# stop with decay from parent crisis
		stop = stop + _rng.randi_range(scenario["decay"][0], scenario["decay"][1])
		var states : Array[String]
		states.assign(scenario["states"])
		
		var dict : Dictionary = {
			"name": scenario["name"],
			"start": start,
			"stop": stop,
			"states": states,
			"desc": scenario["desc"]
		}
		# sorted array
		var index : int = _next_crisis.bsearch_custom(dict, self.sort_start_descending) 
		_next_crisis.insert(index, dict)
		
	if scenario.has("following"):
		var weights : Array[float]
		weights.assign(scenario["following"].map(func(dict : Dictionary) -> float: return dict.get("weight")))
		var returns : Array[int]
		for scene : Dictionary in Global.pick_weighted_random(scenario["following"].duplicate(), weights, _rng.randi_range(scenario["fcount"][0], scenario["fcount"][1])):
			# recursivly generate following crisis
			returns.append(_gen_next_crisis(scene, start, stop))
		
		if root:
			stop = returns.max()
	
			var dict : Dictionary = {
					"name": scenario["name"],
					"start": start,
					"stop": stop,
					"notification": scenario["notification"]
			} 
			# sorted array
			var index : int = _next_crisis.bsearch_custom(dict, self.sort_start_descending, false) 
			_next_crisis.insert(index, dict)
			
		return returns.max()
	return stop

func sort_start_descending(a : Dictionary, b : Dictionary) -> bool:
	return a["start"] > b["start"]

func sort_stop_descending(a : Dictionary, b : Dictionary) -> bool:
	return a["stop"] > b["stop"]
