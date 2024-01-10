extends Control

var _inventory : EMC_Inventory
var _inventory_occupied : int = 0
var _items_to_buy : Array[EMC_Item.IDs] = []
var _balance : int = Global.get_e_coins()

@onready var inventory_grid := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/Shelf/GridContainer
@onready var shop_grid := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/PanelContainer/Shelf/GridContainer
@onready var popup_panel := $PopupPanel


const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_inventory = Global.get_inventory()
	if _inventory == null:
		_inventory = EMC_Inventory.new()
	#_inventory.item_added.connect(_on_item_added)
	#_inventory.item_removed.connect(_on_item_removed)	
	
	for item: EMC_Item.IDs in _inventory.get_all_items_as_ID():
		_add_item_by_id(item, inventory_grid, _on_inventory_item_clicked)
		if item != EMC_Item.IDs.DUMMY:
			_inventory_occupied += 1
	
	for item_id : EMC_Item.IDs in EMC_Item.IDs.values():
		if item_id == EMC_Item.IDs.DUMMY:
			continue
		_add_item_by_id(item_id)

func _add_item_by_id(item_id : EMC_Item.IDs, grid : GridContainer = shop_grid, connect : Callable = _on_shop_item_clicked) -> void:
	var new_slot := _SLOT_SCN.instantiate()
	if item_id != EMC_Item.IDs.DUMMY:
		var new_item := _ITEM_SCN.instantiate()
		new_item.setup(item_id)
		
		# Connect to correct handler
		new_item.clicked.connect(connect)
			
		new_slot.set_item(new_item)
	
	# Add to correct Grid
	grid.add_child(new_slot)
	
func _remove_item_by_id(item : EMC_Item) -> void :
	var i : int = 0
	for slot in inventory_grid.get_children() as Array[EMC_InventorySlot]:
		if i >= _inventory_occupied and slot.get_item() != null and slot.get_item() == item:
			inventory_grid.remove_child(slot)
			_balance += slot.get_item().get_comps() \
				.filter(func(comp : EMC_ItemComponent)->bool: return comp.name == "Cost")[0].get_cost()
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

#func _on_item_added(p_item: EMC_Item, p_idx: int) -> void:
	##p_item.clicked.connect(_on_item_clicked)
	#var slot := inventory_grid.get_child(p_idx)
	#slot.set_item(p_item)


## Update this view when its underlying [EMC_Inventory] structure removed an item
#func _on_item_removed(p_item: EMC_Item, p_idx: int) -> void:
	#var slot := inventory_grid.get_child(p_idx)
	#slot.remove_child(p_item)
	##p_item.clicked.disconnect(_on_item_clicked)

func _on_shop_item_clicked(sender: EMC_Item) -> void:
	_display_info(sender)
	
	var cost : int = 0
	for comp in sender.get_comps():
		if comp.name == "Cost":
			cost = comp.get_cost()

	if _balance - cost >= 0 and _add_item_to_slot_by_id(sender.get_ID()):
		#_inventory.add_new_item(sender.get_ID())
		_balance -= cost
		_items_to_buy.push_back(sender.get_ID())

func _on_inventory_item_clicked(sender : EMC_Item) -> void:
	_display_info(sender)
	_remove_item_by_id.call_deferred(sender)
 
## Display information of clicked [EMC_Item]
func _display_info(sender: EMC_Item) -> void:
	print(_balance)
	
	#Name of the item
	var label_name := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/MarginContainer/PanelContainer2/VBoxContainer/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		comp_string += comp.get_colored_name_with_vals() + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/MarginContainer/PanelContainer2/VBoxContainer/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/MarginContainer/PanelContainer2/VBoxContainer/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")


func _on_home_pressed() -> void:
	Global.set_inventory(_inventory)
	Global.goto_scene("res://preparePhase/main_menu.tscn")


func _on_cancel_pressed() -> void:
	popup_panel.hide()


func _on_buy_pressed() -> void:
	popup_panel.hide()
