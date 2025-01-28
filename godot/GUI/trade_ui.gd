class_name EMC_TradeUI
extends EMC_GUI

@export var mood_texture : AtlasTexture

@onready var portrait : TextureRect = $VBC/Header/HBC/VBC/Portrait
@onready var monologe : RichTextLabel = $VBC/Header/HBC/Baloon/Text
@onready var mood : TextureRect = $VBC/Header/HBC/VBC/Mood

@onready var inventory_grid : EMC_InventoryGrid = $VBC/Inventories/Inventory/InventoryGrid
@onready var trader_grid : EMC_InventoryGrid = $VBC/Inventories/Trader/InventoryGrid

@onready var sell : HBoxContainer = $VBC/Exchange/Sell/HBC
@onready var buy : HBoxContainer = $VBC/Exchange/Buy/HBC

@onready var deal : Button = $VBC/Buttons/Deal

var _PANEL_ITEM_SCN := preload("res://items/panel_item.tscn")

var _inventory : EMC_Inventory
var _gui_mngr : EMC_GUIMngr

var _npc: EMC_NPC
var _npc_inventory : EMC_Inventory
var _npc_initial_score : int

var _sell_items : Array[EMC_Item]
var _buy_items : Array[EMC_Item]

var trade_fairness : float = 0.0

func setup(p_inventory : EMC_Inventory, p_gui_mngr : EMC_GUIMngr) -> void:
	_inventory = p_inventory
	_gui_mngr = p_gui_mngr
	
	inventory_grid.setup(_inventory)
	
	inventory_grid.item_clicked.connect(_on_inventory_item_clicked.bind(true))
	trader_grid.item_clicked.connect(_on_inventory_item_clicked.bind(false))

func open(npc : EMC_NPC) -> void:
	_npc = npc
	_npc_inventory = npc.get_inventory()
	_npc_initial_score = npc.calculate_inventory_score()
	trader_grid.setup(_npc_inventory)
	
	#Reset mood texture
	mood_texture.set_region(Rect2(1 * 64, 0, 64, 64))
	mood.set_texture(mood_texture)
	
	portrait.set_texture(load("res://assets/characters/portrait_" + npc.name.to_lower() + ".png"))
	
	inventory_grid.reload()
	trader_grid.reload()
	
	show()
	
	opened.emit()
	
func close() -> void:
	hide()
	closed.emit(self)

###########################################Private Methods##########################################

func _on_inventory_item_clicked(sender : EMC_Item, backpack : bool) -> void:
	if ((backpack and 
			(sell.get_child_count() >= 5
			or sell.get_child_count() > _npc_inventory.get_free_slot_cnt())) or
		(not backpack and
			(buy.get_child_count() >= 5
			or buy.get_child_count() > _inventory.get_free_slot_cnt()))):
		return
	
	var grid : EMC_InventoryGrid = inventory_grid if backpack else trader_grid
	var to_current : HBoxContainer = sell if backpack else buy
	var to_current_items : Array[EMC_Item] = _sell_items if backpack else _buy_items
	
	var item := grid.pop_item(sender)
	var panel_item := _PANEL_ITEM_SCN.instantiate()
	(panel_item.get_child(0) as EMC_InventorySlot).set_item(item)
	to_current.add_child(panel_item)
	to_current.move_child(panel_item, 0 if backpack else -1)
	to_current_items.push_back(item)
	
	item.clicked.connect(_on_to_trader_item_clicked.bind(backpack), CONNECT_ONE_SHOT)
	item.call_deferred("set_modulate", Color(1, 1, 1))
	
	grid.reload()
	
	_evaluat_trade()

func _on_to_trader_item_clicked(sender : EMC_Item, backpack : bool) -> void:
	monologe.set_text("")
	var to_current : HBoxContainer = sell if backpack else buy
	var to_current_items : Array[EMC_Item] = _sell_items if backpack else _buy_items
	var _current_inventory : EMC_Inventory = _inventory if backpack else _npc_inventory
	var grid : EMC_InventoryGrid = inventory_grid if backpack else trader_grid
	
	var slot : EMC_InventorySlot = sender.get_parent().get_parent()
	if slot != null:
		slot.remove_item()
		
		var panel := slot.get_parent()
		if panel != null:
			panel.get_parent().remove_child(panel)
			panel.queue_free()
		
		to_current_items.erase(sender)
		
		_current_inventory.add_existing_item(sender)
		grid.reload()
	
	_evaluat_trade()

func _evaluat_trade() -> void:
	trade_fairness = _npc.calculate_trade_score(_sell_items) / _npc.calculate_trade_score(_buy_items)
	
	# Math magic XD
	# this is just "step" function to correctly index the smiley faces
	var x : int = clampf(floor(-trade_fairness * 2.0 + 5.0), 0, 4)
	if is_nan(trade_fairness):
		x = 1
	mood_texture.set_region(Rect2(x * 64, 0, 64, 64))
	mood.set_texture(mood_texture)
	
	if trade_fairness >= 0.5:
		deal.disabled = false
	else:
		deal.disabled = true

func _on_cancel_pressed() -> void:
	for item in _sell_items:
		_inventory.add_existing_item(item)
	_sell_items = []
	
	for child : PanelContainer in sell.get_children().slice(0,-1):
		child.get_child(0).remove_item()
		sell.remove_child(child)
		child.queue_free()
	
	for item in _buy_items:
		_npc_inventory.add_existing_item(item)
	_buy_items = []
	
	for child : PanelContainer in buy.get_children().slice(1):
		child.get_child(0).remove_item()
		buy.remove_child(child)
		child.queue_free()
	
	close()

func _on_deal_pressed() -> void:
	if trade_fairness <= 1.0:
		var answer : bool = await _gui_mngr.request_gui("ConfirmationGUI", [_npc.name + " ist nicht sehr zufrieden mit dem Handel
		\n Sicher das du ihn trotzdem eingehen willst.
		\nEs könnte negative Einflüsse auf eure Beziehung haben."])
		
		if not answer:
			return
	
	for item in _buy_items:
		_inventory.add_existing_item(item)
	_buy_items = []
	
	for child : PanelContainer in buy.get_children().slice(1):
		child.get_child(0).remove_item()
		buy.remove_child(child)
		child.queue_free()
		
	for item in _sell_items:
		_npc_inventory.add_existing_item(item)
	_sell_items = []
	
	for child : PanelContainer in sell.get_children().slice(0,-1):
		child.get_child(0).remove_item()
		sell.remove_child(child)
		child.queue_free()
		
	inventory_grid.reload()
	trader_grid.reload()
		
		#if trade_fairness > 1.5:
			#left_dialoge.set_text("I feel ripped of.")
			#text_left.show()
		#elif trade_fairness >= 1.0:
			#right_dialoge.set_text("That was a good trade.")
			#text_right.show()
		#else:
			#right_dialoge.set_text("I accept this trade just beacuse its you.")
			#text_right.show()
		#
	#else:
		#right_dialoge.set_text("I dont like this Trade.")
		#text_right.show()
