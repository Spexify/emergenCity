@tool
extends Control
class_name EMC_Inventory_UI

signal item_clicked(sender : EMC_Item)
signal reloaded

const _slot_scene = preload("res://inventory/item_slot.tscn")

@export var inventory : EMC_Inventory
@export var grid_slot_colums : int = 6

@onready var grid : GridContainer = $SC/Grid

var block_items : Array[EMC_Item]

func _ready() -> void:
	grid.columns = grid_slot_colums
	
	if inventory != null:
		if not inventory.update.is_connected(reload):
			inventory.update.connect(reload)
		reload()

func reload() -> void:
	for child : EMC_Item_Slot in grid.get_children():
		child.queue_free()
		
	var items := inventory.get_items_or_dummy()
	items.sort_custom(EMC_Inventory.sort_by_id_exclusive(block_items))
	for item in items:
		var slot : EMC_Item_Slot = _slot_scene.instantiate()
		slot.set_item(item)
		if item in block_items:
			slot.block()
		if item.is_dummy():
			slot.disable()
			
		if not slot.item_clicked.is_connected(_on_item_clicked):
			slot.item_clicked.connect(_on_item_clicked)
		grid.add_child(slot)
	
	reloaded.emit()
		
func reconnect() -> void:
	for slot in grid.get_children():
		if not slot.item_clicked.is_connected(_on_item_clicked):
			slot.item_clicked.connect(_on_item_clicked, CONNECT_ONE_SHOT)

func set_inventory(value : EMC_Inventory) -> void:
	inventory = value
	if not inventory.update.is_connected(reload):
		inventory.update.connect(reload)
		
func get_inventory() -> EMC_Inventory:
	return inventory

func get_item_slot(item: EMC_Item) -> EMC_Item_Slot:
	for slot: EMC_Item_Slot in grid.get_children():
		if slot.is_item(item):
			return slot
	return null
			
func block_first_items(count : int) -> void:
	for slot : EMC_Item_Slot in grid.get_children().slice(0, count):
		block_items.append(slot.get_item())
		slot.block()
	
func _on_item_clicked(sender : EMC_Item) -> void:
	item_clicked.emit(sender)
