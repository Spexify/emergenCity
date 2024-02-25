extends Node
class_name EMC_CrisisScenario


## can use numbers or key words instead of booleans
var _all_scenarios := {"Flood" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": ""
									},
						"Hurricane" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": ""
									},
						"Drought" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": ""
									},
						"Pandemic" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": ""
									},
						"Earthquake" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": ""
									},
						"Forest Fire" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": ""
									},
						"Chemical Accident" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": ""
									}}

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var LOWER_BOUND : int = 1
var UPPER_BOUND : int = 7

var _scenario := {}

func _init() -> void:
	#print(_all_scenarios.keys())
	match _rng.randi_range(LOWER_BOUND, UPPER_BOUND):
		1:
			_scenario = _all_scenarios["Flood"]
		2:
			_scenario = _all_scenarios["Hurricane"]
		3:
			_scenario = _all_scenarios["Drought"]
		4:
			_scenario = _all_scenarios["Pandemic"]
		5:
			_scenario = _all_scenarios["Earthquake"]
		6:
			_scenario = _all_scenarios["Forest Fire"]
		7:
			_scenario = _all_scenarios["Chemical Accident"]
		_: push_error("Scenario index out of bounds!")
	
func get_scenario() -> Dictionary:
	return _scenario
