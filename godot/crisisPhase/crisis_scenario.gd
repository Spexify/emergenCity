extends Node
class_name EMC_CrisisScenario


## can use numbers or key words instead of booleans
var _all_scenarios := {"Flood" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": "Flood"
									},
						"Hurricane" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": "Hurricane"
									},
						"Drought" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": "Drought"
									},
						"Pandemic" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": "Pandemic"
									},
						"Earthquake" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": "Earthquake"
									},
						"Forest Fire" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									"notification": "Forest Fire"
									},
						"Chemical Accident" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									"notification": "Chemical Accident"
									}}

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

var LOWER_BOUND : int = 1
var UPPER_BOUND : int = _all_scenarios.size()

var _scenario := {}

func _init() -> void:
	var index := _rng.randi_range(LOWER_BOUND, UPPER_BOUND)
	_scenario = _all_scenarios.values()[index-1]
	
	
func get_scenario() -> Dictionary:
	return _scenario
