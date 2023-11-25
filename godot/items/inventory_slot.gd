extends Panel
class_name EC_InventorySlot


#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Prüft, ob der Slot frei ist
## Gibt true zurück, falls der Slot frei ist, sonst false
func is_free() -> bool:
	return $Slot_BG.get_child_count() == 0


func get_item() -> EC_Item:
	if is_free(): return null
	return $Slot_BG.get_child(1)


## Der Slot wird mit einem Item belegt, falls dieser frei ist
## Gibt true zurück, falls das Item gesetzt wurden konnte, sonst false
func set_item(item: EC_Item) -> bool:
	if !is_free(): return false
	$Slot_BG.add_child(item)
	return true


#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
