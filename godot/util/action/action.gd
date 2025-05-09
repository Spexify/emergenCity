extends Resource
class_name EMC_Action

enum IDs{
	NO_ACTION 		= 0,
	CITY_MAP 		= 1,
	COOKING 		= 2, 
	TAP_WATER 		= 3,
	REST 			= 4,
	RAINWATER_BARREL = 5,
	SHOWER 			= 6,
	BBK_LINK		= 7,
	ELECTRIC_RADIO	= 8,
	CRANK_RADIO		= 9,
	WATER_RESERVOIR = 10,
	##1000s = PopupActions
	POPUP_0 = 1000,
	POPUP_1 = 1001,
	##2000s = StageChangeActions
	SC_HOME = 2000,
	SC_MARKET = 2001,
	SC_TOWNHALL = 2002,
	SC_PARK = 2003,
	SC_GARDENHOUSE = 2004,
	SC_ROWHOUSE = 2005,
	SC_MANSION = 2006,
	SC_PENTHOUSE = 2007,
	SC_APARTMENT_MERT = 2008, #Muss in JSON ausgelagert werden
	SC_APARTMENT_CAMPER = 2009, #Muss in JSON ausgelagert werden
	SC_APARTMENT_AGATHE = 2010 #Muss in JSON ausgelagert werden
}

func _init(data: Dictionary) -> void:
	pass

func execute() -> Variant:
	return null

func set_comp(get_exe: Callable) -> void:
	pass
