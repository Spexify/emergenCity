extends EMC_App

@export var warn_texture : Texture2D
@onready var item_list : EMC_Item_List = $VBC/ItemList

func start() -> void:
	item_list.clear()
	
	var x : int = OverworldStatesMngr.get_electricity_state() * 64
	var y : int = OverworldStatesMngr.name_to_state["ElectricityState"][1] * 64
	item_list.add_item(["Der Strom ist " + OverworldStatesMngr.get_electricity_state_descr(), EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))])
	
	x = OverworldStatesMngr.get_water_state() * 64
	y = OverworldStatesMngr.name_to_state["WaterState"][1] * 64
	item_list.add_item(["Das Wasser ist " + OverworldStatesMngr.get_water_state_descr(), EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))])

	x = OverworldStatesMngr.get_isolation_state() * 64
	y = OverworldStatesMngr.name_to_state["IsolationState"][1] * 64
	item_list.add_item(["Es bestehen
	" + OverworldStatesMngr.get_isolation_state_descr(), EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))])
	
	x = OverworldStatesMngr.get_food_contamination_state() * 64
	y = OverworldStatesMngr.name_to_state["FoodContaminationState"][1] * 64
	item_list.add_item(["Der Strom ist " + OverworldStatesMngr.get_food_contamination_state_descr(), EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))])	

	x = OverworldStatesMngr.get_mobile_net_state() * 64
	y = OverworldStatesMngr.name_to_state["MobileNetState"][1] * 64
	item_list.add_item(["Das Mobilefunknetz ist
	momentan " + OverworldStatesMngr.get_mobile_net_state_descr(), EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))])
	
	show()
