extends Panel
class_name EMC_InventorySlot

var _count : int = 1
var _additonal_count : int = 0

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

