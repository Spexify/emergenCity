extends Node
class_name EMC_CrisisScenario


## can use numbers or key words instead of booleans
static var _all_scenarios := JsonMngr.load_scenarios()




#						:= {"Flood" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									#"notification": "Es droht eine Naturkatastrophe. Du hast verschmutztes Wasser, keinen Strom und darfst manche Orte nicht betreten!"
									#},
						#"Hurricane" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									#"notification": "Es droht eine Naturkatastrophe. Du hast kein Wasser, keinen Strom und darfst nicht aus dem Haus raus!"
									#},
						#"Drought" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									#"notification": "Es droht eine Naturkatastrophe. Du hast kein Wasser, verdorbene Lmittel und darfst manche Orte nicht betreten!"
									#},
						#"Pandemic" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									#"notification": "Es droht eine Naturkatastrophe. Du hast verschmutztes Wasser, verdorbene Lebensmittel und darfst manche Orte nicht betreten!"
									#},
						#"Earthquake" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									#"notification": "Es droht eine Naturkatastrophe. Du hast verschmutztes Wasser, keinen Strom und darfst manche Orte nicht betreten!"
									#},
						#"Forest Fire" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.NONE, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.NONE, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.NONE,
									#"notification": "Es droht eine Naturkatastrophe. Du hast kein Wasser, keinen Strom und darfst manche Orte nicht betreten!"
									#},
						#"Chemical Accident" : {"water_crisis" : EMC_OverworldStatesMngr.WaterState.DIRTY, 
									#"electricity_crisis" : EMC_OverworldStatesMngr.ElectricityState.UNLIMITED, 
									#"isolation_crisis" : EMC_OverworldStatesMngr.IsolationState.ISOLATION,
									#"food_contamination_crisis" : EMC_OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED,
									#"notification": "Es droht eine Naturkatastrophe. Du hast verschmutztes Wasser, verdorbene Lebensmittel und darfst nicht aus dem Haus raus!"
									#}}

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

const LOWER_BOUND : int = 1
var UPPER_BOUND : int = _all_scenarios.size()

var crisis_name: String
var allowed_water_crisis: EMC_OverworldStatesMngr.WaterState
var allowed_electricity_crisis: EMC_OverworldStatesMngr.ElectricityState
var allowed_isolation_crisis: EMC_OverworldStatesMngr.IsolationState
var allowed_food_contam_crisis: EMC_OverworldStatesMngr.FoodContaminationState
var notification: String


## Constructor of one scenario instance
func _init() -> void:
	var index := _rng.randi_range(LOWER_BOUND, UPPER_BOUND)
	var scenario_data : Dictionary = _all_scenarios.values()[index-1]
	crisis_name = _all_scenarios.keys()[index-1]
	allowed_water_crisis = scenario_data["water_crisis"]
	allowed_electricity_crisis = scenario_data["electricity_crisis"]
	allowed_isolation_crisis = scenario_data["isolation_crisis"]
	allowed_isolation_crisis = scenario_data["food_contamination_crisis"]
	notification = scenario_data["notification"]
