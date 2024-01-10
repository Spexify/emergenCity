extends Panel
class_name EMC_InventorySlot

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Prüft, ob der Slot frei ist
## Gibt true zurück, falls der Slot frei ist, sonst false
func is_free() -> bool:
	return $Slot_BG.get_child_count() == 0


func get_item() -> EMC_Item:
	if is_free(): return null
	return $Slot_BG.get_child(0)


## Der Slot wird mit einem Item belegt, falls dieser frei ist
## Gibt true zurück, falls das Item gesetzt wurden konnte, sonst false
func set_item(item: EMC_Item) -> bool:
	if !is_free(): return false
	$Slot_BG.add_child(item)
	return true
	
#----------------------------------------- PRIVATE METHODS -----------------------------------------

