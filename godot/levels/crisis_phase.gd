extends Node2D

enum INPUT_MODE{
  default,
  inventory
}

var inventoryScene : PackedScene = preload("res://items/inventory.tscn")
var inputMode : INPUT_MODE = INPUT_MODE.default 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_btn_backpack_pressed():
	toggle_inventory()


func _input(event):	
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		if inputMode == INPUT_MODE.inventory:
			toggle_inventory()
			get_viewport().set_input_as_handled()


func toggle_inventory() -> void:
	var GUINode = get_node("GUI")
	var inventoryGUINode = get_node("GUI/Inventory")
	var btnBackpackNode = get_node("BtnBackpack")
	
	if inputMode == INPUT_MODE.inventory: #hide
		get_node("BtnBackpack").hide()
		btnBackpackNode.show()
		GUINode.hide()
		inventoryGUINode.hide()
		inputMode = INPUT_MODE.default
		
	else: #show
		btnBackpackNode.hide()
		GUINode.show()
		inventoryGUINode.show()
		inputMode = INPUT_MODE.inventory
