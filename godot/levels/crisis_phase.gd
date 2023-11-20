extends Node2D

var inventoryScene : PackedScene = preload("res://items/inventory.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_inventory_closed()
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
	pass # Replace with function body.
