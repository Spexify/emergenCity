extends Control

var _inventory : EMC_Inventory

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
	var acc_count : int = 0
	
	
	for item_id : EMC_Item.IDs in EMC_Item.IDs.values():
		var count : int = _inventory.get_item_count_of_ID(item_id)
		
		if count > 0:
			_add_item_of_id(false, item_id, count)
			acc_count += count
			
	_add_item_of_id(false, EMC_Item.IDs.DUMMY, acc_count)
	
	for item_id : EMC_Item.IDs in EMC_Item.IDs.values():
		if item_id == EMC_Item.IDs.DUMMY:
			continue
		_add_item_of_id(true, item_id, 0)
			
	
func _add_item_of_id(is_shop : bool, item_id : EMC_Item.IDs, count: int) -> void:
	var new_slot := _SLOT_SCN.instantiate()
	if item_id != EMC_Item.IDs.DUMMY:
		var new_item := _ITEM_SCN.instantiate()
		new_item.setup(item_id)
		
		# Connect to correct handler
		if is_shop:
			new_item.clicked.connect(_on_shop_item_clicked)
		else:
			new_item.clicked.connect(_on_inventory_item_clicked)
			
		new_slot.set_item(new_item)
	if count != 0:
		new_slot.set_label_count(count)
		new_slot.show_count()
	
	# Add to correct Grid
	if is_shop:
		shop_grid.add_child(new_slot)
	else:
		inventory_grid.add_child(new_slot)

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
	for item_slot in inventory_grid.get_children():
		var item : EMC_Item = item_slot.get_item()
		if item != null and item.get_ID() == sender.get_ID():
			item_slot.add_additional_count(1)
			item_slot.show_add_count()
 
## Display information of clicked [EMC_Item]
func _on_inventory_item_clicked(sender: EMC_Item) -> void:
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
