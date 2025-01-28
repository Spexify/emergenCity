@tool
extends Panel
class_name EMC_InventorySlot

########################################## PUBLIC METHODS ##########################################

## Checks if slot is free
## Returns true if slot is free, otherwise false
func is_free() -> bool:
	return $Slot_BG.get_child_count() == 0


## Returns item, if an item was set, otherwise null
func get_item() -> EMC_Item:
	if is_free(): return null
	return $Slot_BG.get_child(0)


## If the slot is free, an item is added
## Returns true, if item was successfully set, otherwise false
func set_item(p_item: EMC_Item) -> bool:
	if p_item == null:
		printerr("Item was dem Slot hinzugefügt wurde, ist NULL!")
		return false
	if !is_free(): return false
	$Slot_BG.add_child(p_item)
	return true

func remove_item() -> void:
	if self.is_free():
		return
	var potential_child := $Slot_BG.get_child(0)
	if potential_child != null:
		$Slot_BG.remove_child(potential_child)

func free_item() -> void:
	var potential_child := $Slot_BG.get_child(0)
	if potential_child != null:
		$Slot_BG.remove_child(potential_child)
		potential_child.queue_free()

## Returns item, if an item was set, otherwise null AND removes it
func pop() -> EMC_Item:
	if is_free(): return null
	var item: EMC_Item = get_item()
	remove_item()
	return item
