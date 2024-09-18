class_name EMC_TradeUI
extends EMC_GUI

@onready var portrait_left : TextureRect = $Portaits/HBC/PortraitLeft
@onready var portrait_right : TextureRect = $Portaits/HBC/PortraitRight

@onready var inventory_grid : GridContainer = $Storage/Inventory/SC/Grid
@onready var trader_grid : GridContainer = $Storage/Trader/SC/Grid

@onready var to_trader : HBoxContainer = $Exchange/ToTrader
@onready var to_avatar : HBoxContainer = $Exchange/ToAvatar

var _PANEL_ITEM_SCN := preload("res://items/panel_item.tscn")

var _inventory : EMC_Inventory
var _npc_inventory : EMC_Inventory

func setup(p_inventory : EMC_Inventory) -> void:
	_inventory = p_inventory

func _ready() -> void:
	portrait_left.set_texture(load("res://res/sprites/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png"))

func open(npc : EMC_NPC) -> void:
	_npc_inventory = npc.get_inventory()
	
	show()
	
	portrait_right.set_texture(load("res://res/sprites/characters/portrait_" + npc.name.to_lower() + ".png"))
	
	_load_inventory(true)
	_load_inventory(false)
	
	opened.emit()
	
func close() -> void:
	hide()
	closed.emit(self)

func clear(is_avatar : bool) -> void:
	var gird : GridContainer = inventory_grid if is_avatar else trader_grid
	
	for child : EMC_InventorySlot in gird.get_children():
		if not child.is_free():
			child.free_item()

###########################################Private Methods##########################################

func _load_inventory(is_avatar : bool) -> void:
	clear(is_avatar)
	
	var _current_inventory : EMC_Inventory = _inventory if is_avatar else _npc_inventory
	var gird : GridContainer = inventory_grid if is_avatar else trader_grid
	
	for i in range(_current_inventory.get_slot_cnt()):
		var new_item : EMC_Item 
		var old_item : EMC_Item = _current_inventory.get_item_of_slot(i)
		if old_item != null:
			new_item = EMC_Item.make_from_id(old_item.get_ID())
		else:
			continue
		new_item.clicked.connect(_on_inventory_item_clicked.bind(is_avatar), CONNECT_ONE_SHOT)
		
		(gird.get_child(i) as EMC_InventorySlot).set_item(new_item)

func _on_inventory_item_clicked(sender : EMC_Item, is_avatar : bool) -> void:
	if ((is_avatar and 
			(to_trader.get_child_count() >= 5
			or to_trader.get_child_count() > _npc_inventory.get_free_slot_cnt())) or
		(not is_avatar and
			(to_avatar.get_child_count() >= 5
			or to_avatar.get_child_count() > _inventory.get_free_slot_cnt()))):
		return
	
	var gird : GridContainer = inventory_grid if is_avatar else trader_grid
	var _current_inventory : EMC_Inventory = _inventory if is_avatar else _npc_inventory
	var to_current : HBoxContainer = to_trader if is_avatar else to_avatar
	
	for slot : EMC_InventorySlot in gird.get_children():
		if slot.get_item() == sender:
			slot.remove_item()
			var panel_item := _PANEL_ITEM_SCN.instantiate()
			(panel_item.get_child(0) as EMC_InventorySlot).set_item(sender)
			to_current.add_child(panel_item)
			to_current.move_child(panel_item, 0 if is_avatar else -1)
			
			_current_inventory.remove_item(sender.get_ID())
			
			sender.clicked.connect(_on_to_trader_item_clicked.bind(is_avatar), CONNECT_ONE_SHOT)
			sender.call_deferred("set_modulate", Color(1, 1, 1))
	
			_load_inventory(is_avatar)

func _on_to_trader_item_clicked(sender : EMC_Item, is_avatar : bool) -> void:
	var to_current : HBoxContainer = to_trader if is_avatar else to_avatar
	var _current_inventory : EMC_Inventory = _inventory if is_avatar else _npc_inventory
	
	for child : PanelContainer in to_current.get_children():
		var slot : EMC_InventorySlot = (child.get_child(0) as EMC_InventorySlot)
		if slot == null:
			continue
		if slot.get_item() == sender:
			_current_inventory.add_new_item(sender.get_ID())
			
			to_current.remove_child(child)
			child.queue_free()
			
			_load_inventory(is_avatar)

func _on_cancel_pressed() -> void:
	for child : PanelContainer in to_trader.get_children().slice(0,-1):
		var slot : EMC_InventorySlot = child.get_child(0)
		var item := slot.get_item()
		if item != null:
			_inventory.add_new_item(item.get_ID())
		
		to_trader.remove_child(child)
		child.queue_free()
	
	for child : PanelContainer in to_avatar.get_children().slice(1):
		var slot : EMC_InventorySlot = child.get_child(0)
		var item := slot.get_item()
		if item != null:
			_npc_inventory.add_new_item(item.get_ID())
		
		to_avatar.remove_child(child)
		child.queue_free()
	
	close()

func _on_deal_pressed() -> void:
	for child : PanelContainer in to_avatar.get_children().slice(1):
		var slot : EMC_InventorySlot = child.get_child(0)
		var item := slot.get_item()
		if item != null:
			_inventory.add_new_item(item.get_ID())
		
		to_avatar.remove_child(child)
		child.queue_free()
	
	for child : PanelContainer in to_trader.get_children().slice(0, -1):
		var slot : EMC_InventorySlot = child.get_child(0)
		var item := slot.get_item()
		if item != null:
			_npc_inventory.add_new_item(item.get_ID())
		
		to_trader.remove_child(child)
		child.queue_free()
	
	_load_inventory(true)
	_load_inventory(false)
