extends Control
class_name EMC_CrisisMngr

var _inventory : EMC_Inventory
var _gui_mngr : EMC_GUIMngr
var _max_day : int
var _difficulty : String# OverworldStatesMngr.Difficulty

# Sorted Array (sorted according to the end of the crisis > )
var _current_crisis : Array[Dictionary] = []
# Sorted Array (sorted according to the beginning of the crisis > )
var _next_crisis : Array[Dictionary] = []

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var CRISIS : Dictionary = {}

func setup(p_backpack : EMC_Inventory, p_gui_mngr: EMC_GUIMngr) -> void: 
	_rng.randomize()
	_inventory = p_backpack
	_gui_mngr = p_gui_mngr

	_max_day = OverworldStatesMngr.get_crisis_length()
	_difficulty = OverworldStatesMngr.get_difficulty_str()
	
	CRISIS = JsonMngr.crisis
		#{
		#"Tutorial": [
			#{
				#"name": "0.Tutorial.0",
				#"weight": 1,
				#"descr": "Tutorial",
				#"fcount": [1, 1],
				#"following": ["0.Tutorial.1", "0.Tutorial.2"]
			#}
		#],
		#"Easy": [
			#{
				#"name": "0.Hochwaser.0",
				#"weight": 1,
				#"fcount": [1, 1],
				#"following": ["0.Hochwaser.1", "0.Hochwaser.2"]
			#},
			#{
				#"name": "0.Flut.0",
				#"weight": 1,
				#"fcount": [1, 1],
				#"following": ["0.Flut.1", "0.Flut.2"]
			#}
		#],
		#"following": {
			#"0.Tutorial.1": {
				#"weight": 1,
				#"descr": "Der Strom ist ausgefallen",
				#"duration": [2, 3],
				#"delay": [2, 3],
				#"effects": [
					#{
						#"state": "ElectricityState",
						#"layer": "0.Tutorial",
						#"value": "NONE"
					#}
				#],
				#"fcount": [0, 1],
				#"following": ["0.Tutorial.2"]
			#},
			#"0.Tutorial.2": {
				#"weight": 1,
				#"descr": "Der Strom ist ausgefallen",
				#"duration": [2, 3],
				#"delay": [2, 3],
				#"effects": [
					#{
						#"state": "WaterState",
						#"layer": "0.Tutorial",
						#"value": "NONE"
					#}
				#],
				#"fcount": [0, 0],
				#"following": []
			#}
		#}
	#}#{"": JsonMngr.crisis}
		
############################# GETTERS AND SETTERS ##################################################

func get_max_day() -> int:
	return _max_day

func set_max_day(_p_max_day : int = 3) -> void:
	_max_day = _p_max_day

########################################## PUBLIC METHODS ##########################################


## Reduce countdowns and check the new states
## Returns the value that showed_new_crises() returns
func check_crisis_status(p_period_count : int) -> void:
	if p_period_count >= OverworldStatesMngr.crisis_end:
	
	
		var weights : Array[float]
		weights.assign(CRISIS[_difficulty].map(func(dict : Dictionary) -> float: return dict.get("weight")))
		var scenario : Dictionary = Global.pick_weighted_random(CRISIS[_difficulty], weights, 1)[0]
		
		OverworldStatesMngr.begin_batch()
		var total_duration: int = _helper(scenario, 0, 0) -1
		OverworldStatesMngr.end_batch()
		
		for i in range(total_duration):
			OverworldStatesMngr.add_scenario(scenario["name"], scenario["desc"], i)
		
		OverworldStatesMngr.crisis_end = p_period_count + total_duration
	
		print(total_duration)
	print(OverworldStatesMngr.facility_states)
	print(OverworldStatesMngr.facility_effective_states)
	print()

func _helper(scenario: Dictionary, total_duration: int, start: int) -> int:
	var weights : Array[float]
	var fcount: int = _rng.randi_range(scenario["fcount"][0], scenario["fcount"][1])
	
	if fcount > 0:
		var following: Array[Dictionary]
		for cr_name: String in scenario["following"]:
			var crisis: Dictionary = CRISIS["following"][cr_name]
			following.append(crisis)
			weights.append(crisis["weight"])
			
		following.assign(Global.pick_weighted_random(following, weights, fcount))
		
		for next_crisis: Dictionary in following:
			var duration: int = _rng.randi_range(next_crisis["duration"][0], next_crisis["duration"][1])
			var delay: int = start + _rng.randi_range(next_crisis["delay"][0], next_crisis["delay"][1])
			
			total_duration = max(total_duration, delay + duration)
			
			for effect: Dictionary in next_crisis["effects"]:
				for i in range(duration):
					if effect.has("state"):
						OverworldStatesMngr.add_state_layer_str(effect["state"], effect["layer"], effect["value"], delay+i)
					elif effect.has("flag"):
						OverworldStatesMngr.add_flag_layer(effect["flag"], effect["value"], delay+i)
					OverworldStatesMngr.add_scenario(scenario["name"], next_crisis["desc"], delay+i)
			
			if next_crisis.has("fcount"):
				total_duration = _helper(next_crisis, total_duration, delay + duration)
			
	return total_duration
