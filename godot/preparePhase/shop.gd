extends Control

var _inventory : EMC_Inventory
var _tmp_inventory := EMC_Inventory.new()
var _shop_inventory := EMC_Inventory.new()
var _balance : int = Global.get_e_coins()

@onready var label_ecoins := $Background/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel
@onready var inventory_ui : EMC_Inventory_UI = $Background/Margin/Main/InventorySection/InventoryPanel/Margin/VBox/InventoryUI
@onready var shop_ui : EMC_Inventory_UI = $Background/Margin/Main/ShopSection/ShopPanel/InventoryUI

func _ready() -> void:
	_add_balance(0)
	
	_inventory = Global.get_inventory()
	if _inventory == null:
		_inventory = EMC_Inventory.new()
	
	for item in _inventory.get_dup_items():
		_tmp_inventory.add_item(item)
	
	inventory_ui.set_inventory(_tmp_inventory)
	inventory_ui.reload()
	inventory_ui.block_first_items(_inventory.get_num_item())
	inventory_ui.item_clicked.connect(_on_inventory_item_clicked)
	
	for item_id : EMC_Item.IDs in JsonMngr.get_all_ids():
		if item_id == EMC_Item.IDs.DUMMY:
			continue
		var item := EMC_Item.make_from_id(item_id)
		if item.has_comp(EMC_IC_Cost):
			_shop_inventory.add_item(item)
			
	_shop_inventory.num_slots = _shop_inventory.get_num_item()
	shop_ui.set_inventory(_shop_inventory)
	shop_ui.item_clicked.connect(_on_shop_item_clicked)
	shop_ui.reload()
	#reload()

func reload() -> void:
	shop_ui.reload()
	inventory_ui.reload()

func _on_shop_item_clicked(sender: EMC_Item) -> void:
	_display_info(sender)
	sender.clicked_sound()
	
	var comp := sender.get_comp(EMC_IC_Cost)
	if comp == null:
		return
	
	var cost : int = comp.get_cost()

	var new_item : EMC_Item = EMC_Item.make_from_id(sender.get_id())
	if _balance - cost >= 0 and _tmp_inventory.has_space():
		_tmp_inventory.add_item(new_item)
		_add_balance(-cost)
		
	shop_ui.reconnect()

func _on_inventory_item_clicked(sender : EMC_Item) -> void:
	_display_info(sender)
	_tmp_inventory.remove_item(sender)
	var comp := sender.get_comp(EMC_IC_Cost)
	if comp != null:
		_add_balance(comp.get_cost())

func _add_balance(value : int) -> void:
	_balance += value
	label_ecoins.clear()
	label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")

## Display information of clicked [EMC_Item]
func _display_info(sender: EMC_Item) -> void:
	
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
	_tmp_inventory.sort_custom(EMC_Inventory.sort_by_id)
	Global.set_inventory(_tmp_inventory)
	Global.set_e_coins(_balance)
	Global.goto_scene(Global.MAIN_MENU_SCENE)


func _on_cancel_pressed() -> void:
	Global.set_inventory(_inventory)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
