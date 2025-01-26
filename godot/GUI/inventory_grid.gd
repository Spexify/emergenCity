@tool
extends Control
class_name EMC_InventoryGrid

signal item_clicked(sender : EMC_Item)

const _slot_scene = preload("res://GUI/inventory_slot.tscn")

@export var grid_slot_colums : int = 6
@export var num_slots : int = 30

@onready var grid : GridContainer = $SC/Grid

var _inventory : EMC_Inventory

func _ready() -> void:
	grid.columns = grid_slot_colums
	
	for i in range(num_slots):
		var slot := _slot_scene.instantiate()
		grid.add_child(slot)

func setup(p_inventory : EMC_Inventory) -> void:
	_inventory = p_inventory
	reload()

func reload() -> void:
	for child : EMC_InventorySlot in grid.get_children():
		child.remove_item()
		child.queue_free()
	
	for item_id in _inventory.get_all_item_slots_as_id():
		var slot := _slot_scene.instantiate()
		var item := EMC_Item.make_from_id(item_id)
		if not item.is_dummy():
			slot.set_item(item)
			item.clicked.connect(_on_item_clicked)
		grid.add_child(slot)
		
func pop_item(p_item : EMC_Item) -> EMC_Item:
	var parent : EMC_InventorySlot = p_item.get_parent().get_parent()
	if parent != null:
		p_item.clicked.disconnect(_on_item_clicked)
		_inventory.remove_item(p_item.get_ID())
		return parent.pop()
	return null
	
## Helper
	
func _on_item_clicked(sender : EMC_Item) -> void:
	item_clicked.emit(sender)
