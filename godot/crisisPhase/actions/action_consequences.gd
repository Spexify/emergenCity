extends Node
class_name EMC_ActionConsequences

var _avatar: EMC_Avatar
var _inventory: EMC_Inventory

########################################## PUBLIC METHODS ##########################################
func _init(p_avatar: EMC_Avatar, p_inventory: EMC_Inventory) -> void:
	_avatar = p_avatar
	_inventory = p_inventory


func add_health(p_value: int) -> void:
	_avatar.add_health(p_value)


## Adds the [EMC_Item]
func add_item(p_ID: EMC_Item.IDs) -> void:
	_inventory.add_new_item(p_ID)


## Adds either Water depended on the Water-State
func add_tap_water(_dummy: int) -> void:
	match OverworldStatesMngr.get_water_state():
		OverworldStatesMngr.WaterState.CLEAN:
			_inventory.add_new_item(EMC_Item.IDs.WATER)
		OverworldStatesMngr.WaterState.DIRTY:
			_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
		OverworldStatesMngr.WaterState.NONE:
			printerr("Can't add water while there is no water available! \
				This should be checked in the constraints!")
		_: printerr("Unknown Water state!")
