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

var _npc: EMC_NPC
var _npc_inventory : EMC_Inventory
var _npc_initial_score : int

var _to_trader_items : Array[int]
var _to_avatar_items : Array[int]

func setup(p_inventory : EMC_Inventory) -> void:
	_inventory = p_inventory

func _ready() -> void:
	portrait_left.set_texture(load("res://res/sprites/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png"))

func open(npc : EMC_NPC) -> void:
	_npc = npc
	_npc_inventory = npc.get_inventory()
	_npc_initial_score = npc.calculate_inventory_score()
	
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
	$Portaits/HBC/Text/Margin/TextRight/RichTextLabel.set_text("")
	
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
	var to_current_items : Array[int] = _to_trader_items if is_avatar else _to_avatar_items
	
	for slot : EMC_InventorySlot in gird.get_children():
		if slot.get_item() == sender:
			slot.remove_item()
			var panel_item := _PANEL_ITEM_SCN.instantiate()
			(panel_item.get_child(0) as EMC_InventorySlot).set_item(sender)
			to_current.add_child(panel_item)
			to_current.move_child(panel_item, 0 if is_avatar else -1)
			to_current_items.push_back(sender.get_ID())
			
			_current_inventory.remove_item(sender.get_ID())
			
			sender.clicked.connect(_on_to_trader_item_clicked.bind(is_avatar), CONNECT_ONE_SHOT)
			sender.call_deferred("set_modulate", Color(1, 1, 1))
	
			_load_inventory(is_avatar)

func _on_to_trader_item_clicked(sender : EMC_Item, is_avatar : bool) -> void:
	$Portaits/HBC/Text/Margin/TextRight/RichTextLabel.set_text("")
	var to_current : HBoxContainer = to_trader if is_avatar else to_avatar
	var to_current_items : Array[int] = _to_trader_items if is_avatar else _to_avatar_items
	var _current_inventory : EMC_Inventory = _inventory if is_avatar else _npc_inventory
	
	for child : PanelContainer in to_current.get_children():
		var slot : EMC_InventorySlot = (child.get_child(0) as EMC_InventorySlot)
		if slot == null:
			continue
		if slot.get_item() == sender:
			_current_inventory.add_new_item(sender.get_ID())
			
			to_current.remove_child(child)
			to_current_items.erase(sender.get_ID())
			child.queue_free()
			
			_load_inventory(is_avatar)

func _on_cancel_pressed() -> void:
	$Portaits/HBC/Text/Margin/TextRight/RichTextLabel.set_text("")
	for child : PanelContainer in to_trader.get_children().slice(0,-1):
		to_trader.remove_child(child)
		child.queue_free()
		
	for item_id in _to_trader_items:
		_inventory.add_new_item(item_id)
	_to_trader_items = []
	
	for child : PanelContainer in to_avatar.get_children().slice(1):
		to_avatar.remove_child(child)
		child.queue_free()
		
	for item_id in _to_avatar_items:
		_npc_inventory.add_new_item(item_id)
	_to_avatar_items = []
	
	close()

func _on_deal_pressed() -> void:
	var new_score: int = _npc.calculate_trade_score(_to_trader_items) - _npc.calculate_trade_score(_to_avatar_items)
	if new_score >= 0:
		_npc_initial_score += new_score
		for child : PanelContainer in to_avatar.get_children().slice(1):
			to_avatar.remove_child(child)
			child.queue_free()
			
		for item_id in _to_avatar_items:
			_inventory.add_new_item(item_id)
		_to_avatar_items = []
		
		for child : PanelContainer in to_trader.get_children().slice(0,-1):
			to_trader.remove_child(child)
			child.queue_free()
			
		for item_id in _to_trader_items:
			_npc_inventory.add_new_item(item_id)
		_to_trader_items = []
		
		_load_inventory(true)
		_load_inventory(false)
	else:
		$Portaits/HBC/Text/Margin/TextRight/RichTextLabel.set_text("I dont like this Trade")
