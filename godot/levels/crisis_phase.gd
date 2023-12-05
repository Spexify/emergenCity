extends Node2D

var inventoryScene : PackedScene = preload("res://items/inventory.tscn")

## This is the main node holding all importent informations.
## It will only work when the you run the main scene.
@onready var main : Node = get_node("/root/main")
@onready var uncast_guis = $GUI.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	$GUI/Inventory.close()
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.RAVIOLI);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE);
	$GUI/Inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY);

	if main == null:
		print("The main node could not be found. 
		This may be because you ran the crisis scene directly!")
	
	var guis = []
	for uncast in uncast_guis:
		guis.append(uncast as EMC_GUI)
	
	$DayMngr.setup(guis)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_inventory_closed():
	get_tree().paused = false
	$GUI.hide()
	$BtnBackpack.show()
	pass


func _on_inventory_opened():
	get_tree().paused = true
	$GUI.show()
	$BtnBackpack.hide()
	get_viewport().set_input_as_handled()
	pass
	
	
func _unhandled_input(event):
	if (event is InputEventScreenTouch && event.pressed == true):
		if $GUI/Inventory.visible && !$BtnBackpack.is_pressed():
			$GUI/Inventory.close()

