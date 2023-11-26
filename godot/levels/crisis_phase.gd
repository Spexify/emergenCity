extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$GUI/Inventory.close()
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.RAVIOLI);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_inventory_closed():
	get_tree().paused = false
	$GUI.hide()
	$BtnBackpack.show()
	pass # Replace with function body.


func _on_inventory_opened():
	get_tree().paused = true
	$GUI.show()
	$BtnBackpack.hide()
	get_viewport().set_input_as_handled()
	pass # Replace with function body.
	
	
func _unhandled_input(event):
	if (event is InputEventScreenTouch && event.pressed == true):
		if $GUI/Inventory.visible && !$BtnBackpack.is_pressed():
			$GUI/Inventory.close()

