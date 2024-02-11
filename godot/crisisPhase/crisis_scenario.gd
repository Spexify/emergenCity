extends Node
class_name EMC_CrisisScenario


## can use numbers or key words instead of booleans
var _all_scenarios := {"number 1" : {"water_crisis" : true, 
									"electricity_crisis" : true, 
									"isolation_crisis" : true,
									"food_contamination_crisis" : false
									},
						"number 2" : {"water_crisis" : true, 
									"electricity_crisis" : true, 
									"isolation_crisis" : false,
									"food_contamination_crisis" : true
									},
						"number 3" : {"water_crisis" : false, 
									"electricity_crisis" : true, 
									"isolation_crisis" : true,
									"food_contamination_crisis" : true
									},
						"number 4" : {"water_crisis" : true, 
									"electricity_crisis" : false, 
									"isolation_crisis" : true,
									"food_contamination_crisis" : true
									}}

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var LOWER_BOUND : int = 1
var UPPER_BOUND : int = 4

var _scenario := {}

func _init() -> void:
	#print(_all_scenarios.keys())
	match _rng.randi_range(LOWER_BOUND, UPPER_BOUND):
		1:
			_scenario = _all_scenarios["number 1"]
		2:
			_scenario = _all_scenarios["number 2"]
		3:
			_scenario = _all_scenarios["number 3"]
		4:
			_scenario = _all_scenarios["number 4"]
		_: push_error("Scenario index out of bounds!")
	
func get_scenario() -> Dictionary:
	return _scenario
