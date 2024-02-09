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



## Reduces the uses of the Uses-[EMC_ItemComponent] of the [EMC_Item]
## If it is completely used up, the item is removed from the [EMC_Inventory]
func use_item(p_ID: EMC_Item.IDs) -> void:
	var item := _inventory.get_item_of_ID(p_ID)
	if item == null:
		return
	
	var usesIC: EMC_IC_Uses = item.get_comp(EMC_IC_Uses)
	if usesIC != null:
		usesIC.use_item()
	if usesIC.no_uses_left():
		_inventory.remove_specific_item(item)
