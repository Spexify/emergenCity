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

@onready var open_gui = $SFX/OpenGUI
@onready var close_gui = $SFX/CloseGUI

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
var _inventory: EMC_Inventory

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktro des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden
func setup(p_inventory: EMC_Inventory, p_title: String = "Inventar"):
	_inventory = p_inventory
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_removed.connect(_on_item_removed)
	setTitle(p_title)
	
	for slot_idx in _inventory.get_slot_cnt():
		var new_slot = _SLOT_SCN.instantiate()
		$Background/VBoxContainer/GridContainer.add_child(new_slot)
		#Add items that already are in the inventory
		var item = _inventory.get_item_of_slot(slot_idx)
		if item != null:
			_on_item_added(item, slot_idx)


## Die Überschrift der Inventar-UI setzen
func setTitle(newText: String):
	$Background/Label.text = "[center]" + newText + "[/center]"


## Die Sichtbarkeit umstellen.
func toggleVisibility() -> void:
	if visible == false:
		open()
	else:
		close()


## Das Inventar sichtbar machen.
func open():
	open_gui.play()
	visible = true
	opened.emit()


## Das Inventar verstecken.
func close():
	close_gui.play()
	visible = false
	closed.emit()


#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


## Handle the click on the backpack-button
func _on_btn_backpack_pressed():
	get_viewport().set_input_as_handled()
	open()


## Update this view when its underlying [EMC_Inventory] structure added an item
func _on_item_added(p_item: EMC_Item, p_idx: int):
	p_item.clicked.connect(_on_item_clicked)
	var slot = $Background/VBoxContainer/GridContainer.get_child(p_idx)
	slot.set_item(p_item)


## Update this view when its underlying [EMC_Inventory] structure removed an item
func _on_item_removed(p_item: EMC_Item, p_idx: int):
	p_item.clicked.disconnect(_on_item_clicked)
	var slot = $Background/VBoxContainer/GridContainer.get_child(p_idx)
	slot.remove_child(p_item)


## Display information of clicked [EMC_Item]
func _on_item_clicked(sender: EMC_Item) -> void:
	#Name of the item
	var label_name = $Background/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		comp_string += comp.get_colored_name_with_vals() + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps = $Background/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr = $Background/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")