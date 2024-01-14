extends EMC_GUI
##Die GUI für das Anzeigen eines [EMC_Inventory]s des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.
##
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EMC_InventoryGUI

signal opened
signal closed

@onready var open_gui := $SFX/OpenGUI
@onready var close_gui := $SFX/CloseGUI

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")
var _inventory: EMC_Inventory

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktror des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden
func setup(p_inventory: EMC_Inventory, p_title: String = "Inventar",\
			_only_inventory : bool = true) -> void:
	_inventory = p_inventory
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_removed.connect(_on_item_removed)
	set_title(p_title)
	$Background/VBoxContainer/ScrollContainer.vertical_scroll_mode = false
	
	if _only_inventory:
		$Background/VBoxContainer/Consume.visible = false
	
	#for item: EMC_Item.IDs in _inventory.get_all_items_as_ID():
		#var new_slot := _SLOT_SCN.instantiate()
		#if item != EMC_Item.IDs.DUMMY:
			#var new_item := _ITEM_SCN.instantiate()
			#new_item.setup(item)
			#new_item.clicked.connect(_on_item_clicked)
		#
			#
			#new_slot.set_item(new_item)
	#
		#
		#$Background/VBoxContainer/ScrollContainer/GridContainer.add_child(new_slot)
	
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _SLOT_SCN.instantiate()
		$Background/VBoxContainer/ScrollContainer/GridContainer.add_child(new_slot)
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null:
			_on_item_added(item, slot_idx)


## Set the title of inventory GUI
func set_title(p_new_text: String) -> void:
	$Background/Label.text = "[center]" + p_new_text + "[/center]"


## Open the GUI
func open() -> void:
	open_gui.play()
	show()
	opened.emit()


## Close the GUI
func close() -> void:
	close_gui.play()
	hide()
	closed.emit()


#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


## Handle the click on the backpack-button
func _on_btn_backpack_pressed() -> void:
	get_viewport().set_input_as_handled()
	open()


## Update this view when its underlying [EMC_Inventory] structure added an item
func _on_item_added(p_item: EMC_Item, p_idx: int) -> void:
	p_item.clicked.connect(_on_item_clicked)
	var slot := $Background/VBoxContainer/ScrollContainer/GridContainer.get_child(p_idx)
	if slot == null:
		printerr("InventoryGUI: Slots not initialized properly")
		return
	slot.set_item(p_item)


## Update this view when its underlying [EMC_Inventory] structure removed an item
func _on_item_removed(p_item: EMC_Item, p_idx: int) -> void:
	p_item.clicked.disconnect(_on_item_clicked)
	var slot := $Background/VBoxContainer/ScrollContainer/GridContainer.get_child(p_idx)
	slot.remove_item()


## Display information of clicked [EMC_Item]
func _on_item_clicked(sender: EMC_Item) -> void:
	#Name of the item
	var label_name := $Background/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		comp_string += comp.get_colored_name_with_vals() + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps := $Background/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr := $Background/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")

func set_inventory_height(max_height : int = 250)-> void:
	pass

func _on_consume_pressed() -> void:
	pass # Replace with function body.
