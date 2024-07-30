extends EMC_App

@export var no_elecricity_texture : Texture2D
@export var elecricity_texture : Texture2D

@export var no_water_texture : Texture2D
@export var dirty_water_texture : Texture2D
@export var water_texture : Texture2D

@export var isolation_texture : Texture2D
@export var limited_isolation_texture : Texture2D
@export var no_isolation_texture : Texture2D

@export var no_food_texture : Texture2D
@export var food_spoiled_texture : Texture2D
@export var food_texture : Texture2D

@onready var item_list : ItemList = $ItemList

func start() -> void:
	item_list.clear()
	
	match OverworldStatesMngr.get_electricity_state():
		OverworldStatesMngr.ElectricityState.NONE:
			item_list.add_item("Der Strom ist ausgefallen.", no_elecricity_texture)
		OverworldStatesMngr.ElectricityState.UNLIMITED:
			item_list.add_item("Du hast Strom.", elecricity_texture)
			
	match OverworldStatesMngr.get_water_state():
		OverworldStatesMngr.WaterState.NONE:
			item_list.add_item("Die Wasserleitung ist ausgefallen.", no_water_texture)
		OverworldStatesMngr.WaterState.DIRTY:
			item_list.add_item("Das Wasser ist verdreckt.", dirty_water_texture)
		OverworldStatesMngr.WaterState.CLEAN:
			item_list.add_item("Die Wasserleitung funktionirt einwandsfrei.", water_texture)
			
	match OverworldStatesMngr.get_isolation_state():
		OverworldStatesMngr.IsolationState.ISOLATION:
			item_list.add_item("Du darfst das Haus nicht verlassen.", isolation_texture)
		OverworldStatesMngr.IsolationState.LIMITED_PUBLIC_ACCESS:
			item_list.add_item("Du darfst mache Gebäude nicht betreten.", limited_isolation_texture)
		OverworldStatesMngr.IsolationState.NONE:
			item_list.add_item("Du kannst hingehn wo du willst.", no_isolation_texture)
			
	match OverworldStatesMngr.get_food_contamination_state():
		OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED:
			item_list.add_item("Dein Essen ist ungenießbar.", no_food_texture)
		OverworldStatesMngr.FoodContaminationState.NONE:
			if OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.NONE:
				item_list.add_item("Lebensmittel haben eine gerningere Haltbarkeit.", food_spoiled_texture)
			else:
				item_list.add_item("Es gibt keine Meldungen zu versuchtem Essen.", food_texture)
	
	show()
