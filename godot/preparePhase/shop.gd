extends Control

var _inventory : EMC_Inventory
var _tmp_inventory := EMC_Inventory.new()
var _inventory_occupied : int = 0
var _balance : int = Global.get_e_coins()

@onready var inventory_grid := $Background/Margin/Main/InventorySection/InventoryPanel/Margin/VBox/Shelf/InventoryGrid
@onready var shop_grid := $Background/Margin/Main/ShopSection/ShopPanel/Shelf/ShopGrid
@onready var label_ecoins := $Background/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")

func _ready() -> void:
	_add_balance(0)
	
	_inventory = Global.get_inventory()
	if _inventory == null:
		_inventory = EMC_Inventory.new()
	
	for item: EMC_Item.IDs in _inventory.get_all_items_as_ID():
		_add_item_by_id(item, false)
		if item != EMC_Item.IDs.DUMMY:
			_inventory_occupied += 1
			_tmp_inventory.add_new_item(item)
	
	for item_id : EMC_Item.IDs in JsonMngr.get_all_ids():
		if item_id == EMC_Item.IDs.DUMMY:
			continue
		_add_item_by_id(item_id, true)


func _add_item_by_id(item_id : EMC_Item.IDs, shop : bool) -> void:
	var new_slot := _SLOT_SCN.instantiate()
	if item_id != EMC_Item.IDs.DUMMY:
		var new_item: EMC_Item = _ITEM_SCN.instantiate()
		new_item.setup(item_id)
		var cost_IC := new_item.get_comp(EMC_IC_Cost)
		if shop and cost_IC == null: return
		
		# Connect to correct handler
		if shop:
			new_item.clicked.connect(_on_shop_item_clicked)
		else:
			new_item.clicked.connect(_on_inventory_item_clicked)
			new_slot.modulate = Color(0.3, 0.3, 0.3)
			
		new_slot.set_item(new_item)
	
	# Add to correct Grid
	if shop:
		shop_grid.add_child(new_slot)
	else:
		inventory_grid.add_child(new_slot)


func _remove_item_by_id(item : EMC_Item) -> void :
	var i : int = 0
	for slot in inventory_grid.get_children() as Array[EMC_InventorySlot]:
		if i >= _inventory_occupied and slot.get_item() != null and slot.get_item() == item:
			inventory_grid.remove_child(slot)
			_tmp_inventory.remove_item(item.get_ID(), 1)
			
			var comp := item.get_comp(EMC_IC_Cost)
			assert(comp != null) 
			_add_balance(comp.get_cost())
			
			var new_slot := _SLOT_SCN.instantiate()
			inventory_grid.add_child(new_slot)
			break
		i += 1


func _add_item_to_slot_by_id(item_id : EMC_Item.IDs) -> bool :
	for slot in inventory_grid.get_children() as Array[EMC_InventorySlot]:
		if slot.get_item() == null:
			var new_item := _ITEM_SCN.instantiate()
			new_item.setup(item_id)
			
			new_item.clicked.connect(_on_inventory_item_clicked)
			
			slot.set_item(new_item)
			return true
	return false


func _on_shop_item_clicked(sender: EMC_Item) -> void:
	_display_info(sender)
	
	var comp := sender.get_comp(EMC_IC_Cost)
	if comp == null:
		return
		
	var cost : int = comp.get_cost()

	if _balance - cost >= 0 and _add_item_to_slot_by_id(sender.get_ID()):
		_tmp_inventory.add_new_item(sender.get_ID())
		_add_balance(-cost)


func _on_inventory_item_clicked(sender : EMC_Item) -> void:
	_display_info(sender)
	_remove_item_by_id.call_deferred(sender)


func _add_balance(value : int) -> void:
	_balance += value
	label_ecoins.clear()
	label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")


## Display information of clicked [EMC_Item]
func _display_info(sender: EMC_Item) -> void:
	print(_balance)
	
	#Name of the item
	var label_name := $Background/Margin/Main/InventorySection/InventoryPanel/Margin/VBox/Description/VBox/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		comp_string += comp.get_colored_name_with_vals() + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps := $Background/Margin/Main/InventorySection/InventoryPanel/Margin/VBox/Description/VBox/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr := $Background/Margin/Main/InventorySection/InventoryPanel/Margin/VBox/Description/VBox/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")


func _on_home_pressed() -> void:
	_tmp_inventory.sort_custom(EMC_Inventory.sort_helper)
	Global.set_inventory(_tmp_inventory)
	Global.set_e_coins(_balance)
	Global.goto_scene(Global.MAIN_MENU_SCENE)


func _on_cancel_pressed() -> void:
	Global.set_inventory(_inventory)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
