extends Node2D

var inventoryScene : PackedScene = preload("res://items/inventory.tscn")

@onready var uncast_guis = $GUI.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	$GUI/BackpackGUI.setup(30, "Rucksack")
	$GUI/BackpackGUI.close()
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.WATER);
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.WATER);
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE);
	$GUI/BackpackGUI.add_new_item(EMC_Item.IDs.WATER_DIRTY);
	
	$StageMngr.setup($Avatar)
	
	var guis : Array[EMC_GUI] = []
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
		if $GUI/BackpackGUI.visible && !$BtnBackpack.is_pressed():
			$GUI/BackpackGUI.close()



func _on_summary_end_of_day_gui_closed():

	pass # Replace with function body.


func _on_summary_end_of_day_gui_opened():
	pass # Replace with function body.
