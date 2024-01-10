extends Panel
class_name EMC_InventorySlot

var _count : int = 1
var _additonal_count : int = 0

#------------------------------------------ PUBLIC METHODS -----------------------------------------
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

func set_label_count(count : int) -> void: 
	$Count.set_text("[color=blue]"+str(count)+"x[/color]")
	
func get_label_count() -> int: 
	return _count
	
func add_additional_count(count : int) -> void:
	_additonal_count += count
	$AddCount.set_text("[right][color=green]"+str(_additonal_count)+"x[/color][/right]")

func sub_additional_count(count : int) -> void:
	_additonal_count -= count
	$AddCount.set_text("[right][color=green]"+str(_additonal_count)+"x[/color][/right]")
	
func set_additional_count(count : int) -> void:
	_additonal_count = count
	$AddCount.set_text("[right][color=green]"+str(_additonal_count)+"x[/color][/right]")

func get_additional_count() -> int:
	return _additonal_count
	
func show_count() -> void:
	$Count.visible = true
	
func hide_count() -> void:
	$Count.visible = true
	
func show_add_count() -> void:
	$AddCount.visible = true
	
func hide_add_count() -> void:
	$AddCount.visible = true
	
#----------------------------------------- PRIVATE METHODS -----------------------------------------

