extends Node
## An Inventory (z.B. Backpack of the player, Shelf, etc..)
## To display an inventory you can use [EMC_InventoryGUI].
##
## You can manage the contents of this inventory through its public methods
class_name EMC_Inventory

## For the communication with its according GUI
signal item_added(p_item: EMC_Item, p_idx: int)
## For the communication with its according GUI
signal item_removed(p_item: EMC_Item, p_idx: int)

const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")
const MAX_SLOT_CNT: int = 50

var _slot_cnt: int
var _slots: Array[EMC_Item]

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(p_slot_cnt: int = 30) -> void:
	_slot_cnt = p_slot_cnt
	_slots.resize(_slot_cnt)
	if (_slot_cnt > MAX_SLOT_CNT): _slot_cnt = MAX_SLOT_CNT


func get_slot_cnt() -> int:
	return _slot_cnt


## Returns if the inventory has any free slots left
func has_space() -> bool:
	return get_item_count_total() < _slot_cnt


## Instantiates an new [EMC_Item] Scene and adds it to this inventory.
## Returns true, if the item was added, else false
##
## TODO: Please rename
func add_new_item(p_ID: EMC_Item.IDs) -> bool:
	var new_item: EMC_Item = _ITEM_SCN.instantiate() #EMC_Item.new(ID, self) 
	new_item.setup(p_ID)
	return add_item(new_item)


## Add an already instantiated [EMC_Item] Scene to this inventory.
## This is used if a [EMC_Item] has additional components like durability,
## which should be remembered.
## Returns true, if the item was added, else false
func add_item(p_item: EMC_Item) -> bool:
	if p_item == null: return false
	for slot_idx in _slot_cnt:
		if _slots[slot_idx] == null:
			_slots[slot_idx] = p_item
			item_added.emit(p_item, slot_idx)
			return true
	return false


## Returns item at [p_slot_idx] if available,
## else returns null
## THIS METHOD SHOULD PRIMARILY BE USED BY [EMC_InventoryGUI]!
## Use get_item_of_ID() instead
## Code Review: Method necessary for EMC_InventoryGUI.setup()
func get_item_of_slot(p_slot_idx: int) -> EMC_Item:
	if (p_slot_idx < 0 || p_slot_idx > MAX_SLOT_CNT):
		printerr("Array out of bounds Zugriff.")
		return null
	return _slots[p_slot_idx]


## Returns ID of item at [p_slot_idx] if available,
## else returns null 
func get_item_of_ID(p_ID: EMC_Item.IDs) -> EMC_Item:
	for slot_idx in _slot_cnt:
		var item := _slots[slot_idx]
		if item != null && item.get_ID() == p_ID:
			return item
	return null


## The inventory has at least one item of [p_ID]
func has_item(p_ID: EMC_Item.IDs) -> bool:
	return get_item_of_ID(p_ID) != null


## Returns count of [EMC_Item]s of [p_ID]
func get_item_count_of_ID(p_ID: EMC_Item.IDs) -> int:
	var cnt: int = 0
	
	for slot_idx in _slot_cnt:
		var item: EMC_Item = _slots[slot_idx]
		if item != null and item.get_ID() == p_ID:
			cnt += 1
	return cnt


## Returns total count of [EMC_Item]s in inventory
func get_item_count_total() -> int:
	var cnt: int = 0
	
	for slot_idx in _slot_cnt:
		var item := _slots[slot_idx]
		if item != null:
			cnt += 1
		##Mini-Optimization that can be used in the future, when the array is guaranteed to always be sorted:
		#else:
			#break
	return cnt

## Return all items as Array of [EMC_Item]s
func get_all_items() -> Array[EMC_Item]:
	var items: Array[EMC_Item] = []
	
	for slotIdx in _slot_cnt:
		var slot: EMC_InventorySlot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item := slot.get_item()
		if item != null:
			items.push_back(item)
	return items
	
## Returns copy of all item IDs ([EMC_Item.IDs]) and empty spaces as [EMC_Item.IDs.DUMMY]
func get_all_items_as_ID() -> Array[EMC_Item.IDs]:
	var items : Array[EMC_Item.IDs] = []
	for item in _slots:
		items.push_back(item.get_ID() if item != null else EMC_Item.IDs.DUMMY)
	return items

## Return all items as Array of [EMC_Item]s for an ID
## CodeReview TODO: Add to_get_cnt parameter, with to_get_cnt = -1 => all items
func get_all_items_of_ID(p_ID: EMC_Item.IDs) -> Array[EMC_Item]:
	var items := get_all_items()
	for slot_idx in items.size():
		if items[slot_idx].get_ID() != p_ID:
			items.remove_at(slot_idx)
	return items


## Remove [EMC_Item] [to_be_removed_cnt] times from this inventory
## Returns the count of successfully removed items
func remove_item(ID: EMC_Item.IDs, to_be_removed_cnt: int = 1) -> int:
	var removedCnt: int = 0
	
	for slot_idx in _slot_cnt:
		var item := _slots[slot_idx]
		if item != null && item.get_ID() == ID:
			_slots[slot_idx] = null
			item_removed.emit(item, slot_idx)
			removedCnt += 1
			if removedCnt == to_be_removed_cnt: break
	return removedCnt
	

## TODO: rework, shading non consumables
## KL: Filter Funktion, die nur die Items übergibt, die den Filterkriterium entsprechen
## Variable food_or_drink hat 2 Werte : 0 falls es nach EMC_IC_Food Items gefiltert wird, 
## 										1, falls es nach EMC_IC_Drink gefiltert wird

func filter_items() -> void:
	pass

### Sort Items (by ID?) -> TODO
#func sort() -> void: #Man könnte ein enum als Parameter ergänzen, nach was sortiert werden soll
	##TODO (keine Prio)
	#pass
