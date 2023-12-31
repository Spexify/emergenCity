extends Control

var _inventory : EMC_Inventory

@onready var inventory_grid := $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/Shelf/GridContainer

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_inventory = Global.get_inventory()
	if _inventory == null:
		_inventory = EMC_Inventory.new()
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_removed.connect(_on_item_removed)
	
	for slot_idx in _inventory.get_slot_cnt():
		var new_slot := _SLOT_SCN.instantiate()
		inventory_grid.add_child(new_slot)
		
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null:
			_on_item_added(item, slot_idx)

func _on_item_added(p_item: EMC_Item, p_idx: int) -> void:
	#p_item.clicked.connect(_on_item_clicked)
	var slot := inventory_grid.get_child(p_idx)
	slot.set_item(p_item)


## Update this view when its underlying [EMC_Inventory] structure removed an item
func _on_item_removed(p_item: EMC_Item, p_idx: int) -> void:
	var slot := inventory_grid.get_child(p_idx)
	slot.remove_child(p_item)
	#p_item.clicked.disconnect(_on_item_clicked)


## Display information of clicked [EMC_Item]
#func _on_item_clicked(sender: EMC_Item) -> void:
	##Name of the item
	#var label_name = $Background/VBoxContainer/MarginContainer/TextBoxBG/Name
	#label_name.clear()
	#label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	#
	##Components of item
	#var comps := sender.get_comps()
	#var comp_string: String = ""
	#for comp in comps:
		#comp_string += comp.get_colored_name_with_vals() + ", "
	##Remove superfluous comma:
	#comp_string = comp_string.left(comp_string.length() - 2)
	#var label_comps = $Background/VBoxContainer/MarginContainer/TextBoxBG/Components
	#label_comps.clear()
	#label_comps.append_text("[color=black]" + comp_string + "[/color]")
	#
	##Description of item:
	#var label_descr = $Background/VBoxContainer/MarginContainer/TextBoxBG/Description
	#label_descr.clear()
	#label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")
