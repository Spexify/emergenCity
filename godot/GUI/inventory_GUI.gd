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
signal close_button
signal chlor_tablets_clicked

@onready var open_gui := $SFX/OpenGUI
@onready var close_gui := $SFX/CloseGUI

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")
var _inventory: EMC_Inventory
var _clicked_item : EMC_Item
var _avatar_ref : EMC_Avatar
var _only_inventory : bool

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktror des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden
func setup(p_inventory: EMC_Inventory, _p_avatar_ref : EMC_Avatar, p_title: String = "Inventar",\
			_p_only_inventory : bool = true) -> void:
	_avatar_ref = _p_avatar_ref
	_inventory = p_inventory
	_only_inventory = _p_only_inventory
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_removed.connect(_on_item_removed)
	set_title(p_title)
	
	$Inventory/VBoxContainer/HBoxContainer/Consume.visible = false
	$Inventory/VBoxContainer/HBoxContainer/Continue.visible = false
	$Inventory/VBoxContainer/HBoxContainer/Discard.visible = false
	$FilterWater.visible = false
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
		#$Inventory/VBoxContainer/ScrollContainer/GridContainer.add_child(new_slot)
	
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _SLOT_SCN.instantiate()
		$Inventory/VBoxContainer/ScrollContainer/GridContainer.add_child(new_slot)
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null:
			_on_item_added(item, slot_idx)
			item.show()

func set_consume_active() -> void:
	_only_inventory = false
	$Inventory/VBoxContainer/HBoxContainer/Consume.visible = true
	$Inventory/VBoxContainer/HBoxContainer/Continue.visible = true

## Set the title of inventory GUI
func set_title(p_new_text: String) -> void:
	$Inventory/Label.text = "[center]" + p_new_text + "[/center]"

func set_grid_height(height : int = 400) -> void:
	$Inventory/VBoxContainer/ScrollContainer.custom_minimum_size.y = height

func clear_items() -> void:
	for slot in $Inventory/VBoxContainer/ScrollContainer/GridContainer.get_children():
		slot.remove_item()
		
## TODO: Karina
func update_items() -> void:
	for slot_idx in _inventory.get_slot_cnt():
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null:
			print(item)
			var duplicated := item.copy_item()
			duplicated.setup(duplicated.get_ID())
			print("duplicate")
			print(duplicated)
			_on_item_added(duplicated, slot_idx)
			
			
## Open the GUI
func open() -> void:
	open_gui.play()
	show()
	opened.emit()


## Close the GUI
func close() -> void:
	if !_only_inventory: 
		close_button.emit()
	close_gui.play()
	hide()
	closed.emit()


#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


## Handle the click on the backpack-button
func _on_btn_backpack_pressed() -> void:
	if visible == false:
		get_viewport().set_input_as_handled()
		open()
	else:
		close()


## Update this view when its underlying [EMC_Inventory] structure added an item
func _on_item_added(p_item: EMC_Item, p_idx: int) -> void:
	p_item.clicked.connect(_on_item_clicked)
	var slot := $Inventory/VBoxContainer/ScrollContainer/GridContainer.get_child(p_idx)
	if slot == null:
		printerr("InventoryGUI: Slots not initialized properly")
		return
	slot.set_item(p_item)


## Update this view when its underlying [EMC_Inventory] structure removed an item
func _on_item_removed(p_item: EMC_Item, p_idx: int) -> void:
	p_item.clicked.disconnect(_on_item_clicked)
	var slot := $Inventory/VBoxContainer/ScrollContainer/GridContainer.get_child(p_idx)
	slot.remove_item()


## Display information of clicked [EMC_Item]
func _on_item_clicked(sender: EMC_Item) -> void:
	_clicked_item = sender
	$Inventory/VBoxContainer/HBoxContainer/Discard.visible = true
	
	#Name of the item
	var label_name := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		var comp_text := comp.get_colored_name_with_vals()
		if comp_text != "":
			comp_string += comp_text + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")
	
	## if the Chlor tablets are clicked, open water filtering gui
	if sender.get_ID() == 13:
		$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Filtern"
		$Inventory/VBoxContainer/HBoxContainer/Consume.visible = true
		##open gui and ask if water should be filtered, if there is available water
		pass
			

func _on_consume_pressed() -> void:
	
	var has_drank : bool = false
	var has_eaten : bool = false
	if _clicked_item == null:
		return
	if _clicked_item.get_ID() == 13:
		#$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Filtern"
		if !_inventory.has_item(2):
			$FilterWater.visible = true
		else:
			_clicked_item.get_comp(EMC_IC_Uses).item_used(1)
			if  _clicked_item.get_comp(EMC_IC_Uses).get_uses_left() == 0:
				_inventory.remove_item(13,1)
			_inventory.remove_item(2,1)
			_inventory.add_new_item(1)
	var drink_comp : EMC_IC_Drink = _clicked_item.get_comp(EMC_IC_Drink)
	if  drink_comp!= null:
		#$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Trink"
		_avatar_ref.add_hydration(drink_comp.get_hydration())
		has_drank = true
	var food_comp : EMC_IC_Food = _clicked_item.get_comp(EMC_IC_Food)
	if food_comp != null:
		#$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Iss"
		print(food_comp.get_nutritionness())
		_avatar_ref.add_nutrition(food_comp.get_nutritionness())
		has_eaten = true
	if has_drank && has_eaten: 
		_avatar_ref.add_health(1)
	_inventory.remove_item(_clicked_item._ID)
	_inventory.item_removed.emit()
	return


func _on_discard_pressed() -> void:
	_inventory.remove_item(_clicked_item.get_ID(),1)


func _on_cancel_pressed() -> void:
	$FilterWater.visible = false
