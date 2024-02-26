extends EMC_GUI
##Die GUI für das Anzeigen eines [EMC_Inventory]s des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.
##
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EMC_InventoryGUI

signal close_button
signal chlor_tablets_clicked
signal seod_inventory_closed

@onready var _slot_grid := $Inventory/VBoxContainer/ScrollContainer/GridContainer

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")
const _ITEM_SCN: PackedScene = preload("res://items/item.tscn")
var _inventory: EMC_Inventory
var _clicked_item : EMC_Item
var _avatar_ref : EMC_Avatar
var _only_inventory : bool
var _seod : EMC_SummaryEndOfDayGUI

var _has_slept : int = 0

########################################## PUBLIC METHODS ##########################################
## Konstruktror des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden

func setup(p_inventory: EMC_Inventory, _p_avatar_ref : EMC_Avatar, _p_seod : EMC_SummaryEndOfDayGUI, p_title: String = "Inventar",\
			_p_only_inventory : bool = true) -> void:
	_inventory = p_inventory
	_avatar_ref = _p_avatar_ref
	_only_inventory = _p_only_inventory
	_seod = _p_seod
	set_title(p_title)

	$Inventory/VBoxContainer/HBoxContainer/Consume.hide()
	$Inventory/VBoxContainer/HBoxContainer/Continue.hide()
	$Inventory/VBoxContainer/HBoxContainer/Discard.hide()
	$FilterWater.hide()
	
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _SLOT_SCN.instantiate()
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null and item.get_ID() != JsonMngr.name_to_id("DUMMY"):
			item.clicked.connect(_on_item_clicked)
			new_slot.set_item(item)
		_slot_grid.add_child(new_slot)


func set_consume_active( _p_has_slept : int = 0) -> void:
	_has_slept =  _p_has_slept
	_only_inventory = false
	#$Inventory/VBoxContainer/HBoxContainer/Consume.visible = true
	$Inventory/VBoxContainer/HBoxContainer/Continue.visible = true

func set_consume_idle() -> void:
	_only_inventory = true  #MRM Bugfix
	#$Inventory/VBoxContainer/HBoxContainer/Consume.visible = false
	$Inventory/VBoxContainer/HBoxContainer/Continue.visible = false #MRM Bugfix

## Set the title of inventory GUI
func set_title(p_new_text: String) -> void:
	$Inventory/Label.text = "[center]" + p_new_text + "[/center]"

func set_grid_height(height : int = 400) -> void:
	$Inventory/VBoxContainer/ScrollContainer.custom_minimum_size.y = height

func clear_items() -> void:
	for slot in $Inventory/VBoxContainer/ScrollContainer/GridContainer.get_children():
		slot.remove_item()


### TODO: Karina
#func update_items() -> void:
	#for slot_idx in _inventory.get_slot_cnt():
		##Add items that already are in the inventory
		#var item := _inventory.get_item_of_slot(slot_idx)
		#if item != null:
			#print(item)
			#var duplicated := item.copy_item()
			#duplicated.setup(duplicated.get_ID())
			#print("duplicate")
			#print(duplicated)
			#_on_item_added(duplicated, slot_idx)


## Open the GUI
func open() -> void:
	_clicked_item = null
	show()
	get_tree().paused = true
	opened.emit()
	_reload_items()


## Close the GUI
func close() -> void:
	_clear_gui()
	close_button.emit()
	#close_gui.play()
	hide()
	get_tree().paused = false
	closed.emit()
	if !_only_inventory:
		set_consume_idle()
		if _has_slept != 0:
			_avatar_ref.add_health(_has_slept)
		_has_slept = 0
		_avatar_ref.get_home()
		_seod.close()
	seod_inventory_closed.emit()


########################################## PRIVATE METHODS #########################################
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
		
func _clear_gui() -> void:
	#Name of the item
	var label_name := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	
	var label_comps := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	
	#Description of item:
	var label_descr := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	
	$Inventory/VBoxContainer/HBoxContainer/Consume.visible = false
	$Inventory/VBoxContainer/HBoxContainer/Discard.visible = false
	
## Display information of clicked [EMC_Item]
## Call with [param sender] == null to clear to default state.
func _on_item_clicked(sender: EMC_Item) -> void:
	_clicked_item = sender
	
	#Name of the item
	var label_name := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Components of item
	var comp_string: String = ""
	var label_comps := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	
	var comps := sender.get_comps()
	for comp in comps:
		var comp_text := comp.get_colored_name_with_vals()
		if comp_text != "":
			comp_string += comp_text + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	var label_descr := $Inventory/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	label_descr.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")
	
	## if the Chlor tablets are clicked, open water filtering gui
	if sender.get_ID() == JsonMngr.name_to_id("CHLOR_TABLETS"):
		$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Filtern"
		$Inventory/VBoxContainer/HBoxContainer/Consume.visible = true
		if _only_inventory:
			$Inventory/VBoxContainer/HBoxContainer/Discard.visible = true
	else:
		$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Konsumieren"
		
		if _only_inventory:
			$Inventory/VBoxContainer/HBoxContainer/Consume.visible = false
			$Inventory/VBoxContainer/HBoxContainer/Discard.visible = true
		elif _item_consumable(_clicked_item):
			$Inventory/VBoxContainer/HBoxContainer/Consume.visible = true
		else:
			$Inventory/VBoxContainer/HBoxContainer/Consume.visible = false

func _item_consumable(item : EMC_Item) -> bool:
	return item.get_comp(EMC_IC_Drink) != null or item.get_comp(EMC_IC_Food) != null

func _remove_item(item : EMC_Item) -> void:
	for slot in _slot_grid.get_children():
		if slot.get_item() == item:
			slot.remove_item()

func _remove_item_by_id(item_id : int) -> void:
	for slot in _slot_grid.get_children():
		if slot.get_item().get_ID() == item_id:
			slot.remove_item()
			return
			
func _reload_items() -> void:
	_inventory.sort_custom(EMC_Inventory.sort_helper)
	
	for child in _slot_grid.get_children():
		child.remove_item()
		_slot_grid.remove_child(child)
	
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _SLOT_SCN.instantiate()
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null and item.get_ID() != JsonMngr.name_to_id("DUMMY"):
			item.clicked.connect(_on_item_clicked)
			new_slot.set_item(item)
		_slot_grid.add_child(new_slot)
		
#MRM: TODO: Remove Magic Numbers
func _on_consume_pressed() -> void:
	if _clicked_item == null:
		return
	if _clicked_item.get_ID() == JsonMngr.name_to_id("CHLOR_TABLETS"): 
		#$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Filtern"
		if !_inventory.has_item(JsonMngr.name_to_id("WATER_DIRTY")):
			$FilterWater.visible = true
		else:
			##Improvement idea: use new _inventory.use_item() method
			var comp_uses : EMC_IC_Uses = _clicked_item.get_comp(EMC_IC_Uses)
			comp_uses.use_item(1)
			# Work around to stop gray modulate
			_clicked_item._on_clicked(EMC_Item.new())
				
			if comp_uses.no_uses_left():
				_inventory.remove_item(_clicked_item.get_ID())
			
			_inventory.remove_item(JsonMngr.name_to_id("WATER_DIRTY"))
			_inventory.add_new_item(JsonMngr.name_to_id("WATER"))
	else:
		var drink_comp : EMC_IC_Drink = _clicked_item.get_comp(EMC_IC_Drink)
		var food_comp : EMC_IC_Food = _clicked_item.get_comp(EMC_IC_Food)
		if  drink_comp != null:
			_avatar_ref.add_hydration(drink_comp.get_hydration())
		if food_comp != null:
			print(food_comp.get_nutritionness())
			_avatar_ref.add_nutrition(food_comp.get_nutritionness())
		var unpalatable_comp : EMC_IC_Unpalatable = _clicked_item.get_comp(EMC_IC_Unpalatable)
		if unpalatable_comp != null:
			_avatar_ref.sub_health(unpalatable_comp.get_health_reduction())
		
		var pleasurable_comp : EMC_IC_Pleasurable = _clicked_item.get_comp(EMC_IC_Pleasurable)
		if pleasurable_comp != null:
			if pleasurable_comp.get_happinness_change() < 0:
				_avatar_ref.sub_happinness(pleasurable_comp.get_happinness_change())
			elif pleasurable_comp.get_happinness_change() >= 0 :
				_avatar_ref.add_happinness(pleasurable_comp.get_happinness_change())
				
		var healthy_comp : EMC_IC_Healthy = _clicked_item.get_comp(EMC_IC_Healthy)
		if healthy_comp != null:
			if healthy_comp.get_health_change() < 0:
				_avatar_ref.sub_health(healthy_comp.get_health_change())
			elif healthy_comp.get_health_change() >= 0 :
				_avatar_ref.add_health(healthy_comp.get_health_change())
				
		var hydrating_comp : EMC_IC_Hydrating = _clicked_item.get_comp(EMC_IC_Hydrating)
		if hydrating_comp != null:
			if hydrating_comp.get_hydration_change() < 0:
				_avatar_ref.sub_hydration(hydrating_comp.get_hydration_change())
			elif hydrating_comp.get_hydration_change() >= 0 :
				_avatar_ref.add_hydration(hydrating_comp.get_hydration_change())

		# Work around to stop gray modulate
		_clicked_item._on_clicked(EMC_Item.new())
		_inventory.remove_item(_clicked_item._ID)
		
	_reload_items()
	_clear_gui()

func _on_discard_pressed() -> void:
	_inventory.remove_item(_clicked_item.get_ID(),1)
	_reload_items()
	_clear_gui()

func _on_cancel_pressed() -> void:
	$FilterWater.visible = false
